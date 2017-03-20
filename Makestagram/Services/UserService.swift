//
//  UserService.swift
//  Makestagram
//
//  Created by Chase Wang on 3/15/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserService {
    
    static func timeline(forUID uid: String, completion: @escaping ([Post]) -> Void) {
        let dbRef = FIRDatabase.database().reference()
        
        _ = dbRef.child("timeline").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]
                else { return completion([]) }
            
            let dispatchGroup = DispatchGroup()
            
            var posts = [Post]()
            for postSnap in snapshot {
                guard let postDict = postSnap.value as? [String : Any],
                    let posterUID = postDict["poster_uid"] as? String
                    else { continue }
                
                dispatchGroup.enter()
                
                PostService.showPostForKey(postSnap.key, posterUID: posterUID, completion: { (post) in
                    if let post = post {
                        posts.append(post)
                    }
                    
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                // TODO: better way of ordering... wtf can't do this server side w firebase
                completion(posts.reversed())
            })
        })
    }
    
    static func allFollowers(forUID uid: String, completion: @escaping ([String]) -> Void) {
        let dbRef = FIRDatabase.database().reference()
        
        let followersRef = dbRef.child("followers").child(uid)
        followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let followersDict = snapshot.value as? [String : Bool] else {
                return completion([])
            }
            
            let followersKeys = Array(followersDict.keys)
            completion(followersKeys)
        })
    }
    
    static func createUser(_ username: String, forUID uid: String, completion: ((Error?) -> Void)? = nil) {
        let dbRef = FIRDatabase.database().reference()
        
        let userAttrs: [String : Any] = ["username": username,
                                         "followers_count": 0,
                                         "following_count" : 0,
                                         "posts_count" : 0]
        
        dbRef.child("users").child(uid).setValue(userAttrs) { (error, ref) in
            completion?(error)
        }
    }
    
    static func isUser(_ uid: String, beingFollowedbyOtherUser otherUID: String, completion: @escaping (Bool) -> Void) {
        let dbRef = FIRDatabase.database().reference()
        
        dbRef.child("followers/\(uid)").queryEqual(toValue: nil, childKey: otherUID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let _ = snapshot.value as? [String : Bool] else {
                return completion(false)
            }
            
            completion(true)
        })
    }
    
    static func showUser(_ user: User, currentUser: User, completion: @escaping (User?) -> Void) {
        let dbRef = FIRDatabase.database().reference()
        
        _ = dbRef.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else { return completion(nil) }
            
            guard user.uid != currentUser.uid else { return completion(user) }
            
            isUser(user.uid, beingFollowedbyOtherUser: currentUser.uid, completion: { (isFollowed) in
                user.isFollowed = isFollowed
                completion(user)
            })
        })
    }
    
    static func allUsers(for currentUser: User, completion: @escaping ([User]) -> Void) {
        let dbRef = FIRDatabase.database().reference()
        
        _ = dbRef.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allUsers = snapshot.children.allObjects as? [FIRDataSnapshot]
                else { return completion([]) }
            
            var users = [User]()
            let dispatchGroup = DispatchGroup()
            
            for user in allUsers {
                guard let user = User(snapshot: user),
                    user.uid != currentUser.uid
                    else { continue }
                
                dispatchGroup.enter()
                
                isUser(user.uid, beingFollowedbyOtherUser: currentUser.uid, completion: { (isFollowed) in
                    user.isFollowed = isFollowed
                    users.append(user)

                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(users)
            })
        })
    }
    
    
    
    
    
    
    
    static func followUser(_ userToFollow: User, completion: @escaping (Bool) -> Void) {
        guard let currentUID = User.current?.uid, !userToFollow.isFollowed
            else { return completion(false) }
        
        let dbRef = FIRDatabase.database().reference()
        
        let followData: [String : Any?] = ["followers/\(userToFollow.uid)/\(currentUID)" : true,
                                           "following/\(currentUID)/\(userToFollow.uid)" : true]
        
        dbRef.updateChildValues(followData) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(false)
            }
            
            let dispatchGroup = DispatchGroup()
            
            // update following
            
            dispatchGroup.enter()
            let followingCountRef = dbRef.child("users").child(currentUID).child("following_count")
            followingCountRef.runTransactionBlock({ (followingData) -> FIRTransactionResult in
                let followingCount = followingData.value as? Int ?? 0
                followingData.value = followingCount + 1
                
                return FIRTransactionResult.success(withValue: followingData)
            }, andCompletionBlock: { (error, committed, snapshot) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                
                dispatchGroup.leave()
            })
            
            // update followers
            
            dispatchGroup.enter()
            let followersCountRef = dbRef.child("users").child(userToFollow.uid).child("followers_count")
            followersCountRef.runTransactionBlock({ (followersData) -> FIRTransactionResult in
                
                
                let followersCount = followersData.value as? Int ?? 0
                followersData.value = followersCount + 1
                
                return FIRTransactionResult.success(withValue: followersData)
            }, andCompletionBlock: { (error, committed, snapshot) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                
                dispatchGroup.leave()
            })
            
            // get user and fetch their posts.. and add each one from timeline
            // fetching when a post is liked for each user!!! crazy... how can we make this better
            dispatchGroup.enter()
            PostService.allPosts(forUID: userToFollow.uid, completion: { (posts) in
                
                var followData = [String : Any?]()
                let postsKeys = posts.flatMap { $0.key }
                
                let timelinePostDict: [String : Any] = ["poster_uid" : userToFollow.uid]
                postsKeys.forEach { followData["timeline/\(currentUID)/\($0)"] = timelinePostDict }
                
                dbRef.updateChildValues(followData, withCompletionBlock: { (error, ref) in
                    dispatchGroup.leave()
                })
            })
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(true)
            })
        }
        
    }
    
    static func unfollowUser(_ userToUnfollow: User, completion: @escaping (Bool) -> Void) {
        guard let currentUID = User.current?.uid, userToUnfollow.isFollowed
            else { return completion(false) }
        
        let dbRef = FIRDatabase.database().reference()
        
        let unfollowData: [String : Any?] = ["followers/\(userToUnfollow.uid)/\(currentUID)" : nil,
                                             "following/\(currentUID)/\(userToUnfollow.uid)" : nil]
        
        dbRef.updateChildValues(unfollowData) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(false)
            }
            
            let dispatchGroup = DispatchGroup()
            
            // update following
            
            dispatchGroup.enter()
            let followingCountRef = dbRef.child("users").child(currentUID).child("following_count")
            followingCountRef.runTransactionBlock({ (followingData) -> FIRTransactionResult in
                let followingCount = followingData.value as? Int ?? 0
                followingData.value = followingCount - 1
                
                return FIRTransactionResult.success(withValue: followingData)
            }, andCompletionBlock: { (error, committed, snapshot) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                
                dispatchGroup.leave()
            })
            
            // update followers
            
            dispatchGroup.enter()
            let followersCountRef = dbRef.child("users").child(userToUnfollow.uid).child("followers_count")
            followersCountRef.runTransactionBlock({ (followersData) -> FIRTransactionResult in
                
                
                let followersCount = followersData.value as? Int ?? 0
                followersData.value = followersCount - 1
                
                return FIRTransactionResult.success(withValue: followersData)
            }, andCompletionBlock: { (error, committed, snapshot) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                
                dispatchGroup.leave()
            })
            
            // get user and fetch their posts.. and remove each one from timeline
            // fetching when a post is liked for each user!!! crazy... how can we make this better
            dispatchGroup.enter()
            PostService.allPosts(forUID: userToUnfollow.uid, completion: { (posts) in
                
                var unfollowData = [String : Any?]()
                let postsKeys = posts.flatMap { $0.key }
                postsKeys.forEach {
                    // nil must be cast as Any? otherwise dictionary will not be set
                    // http://stackoverflow.com/questions/26544573/how-to-add-nil-value-to-swift-dictionary
                    unfollowData["timeline/\(currentUID)/\($0)"] = nil as Any?
                }

                dbRef.updateChildValues(unfollowData, withCompletionBlock: { (error, ref) in
                    dispatchGroup.leave()
                })
            })
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(true)
            })
        }
    }
    
    
    
    
    
    
    
    
    
    
//    static func oldFollowCode() {
//        guard let currentUser = User.current else { return completion(false) }
//        
//        let dbRef = FIRDatabase.database().reference()
//        
//        // TODO: add logic to add/remove all posts from user timeline
//        
//        // TODO: change this to be explicit, move logic to controller
//        let followValue: Bool? = userToFollow.isFollowed ? nil : true
//        let followData: [String : Any?] = ["followers/\(userToFollow.uid)/\(currentUser.uid)" : followValue,
//                                           "following/\(currentUser.uid)/\(userToFollow.uid)" : followValue]
//        
//        dbRef.updateChildValues(followData) { (error, ref) in
//            guard error == nil else {
//                return completion(false)
//            }
//            
//            let dispatchGroup = DispatchGroup()
//            
//            // update following
//            
//            dispatchGroup.enter()
//            let followingCountRef = dbRef.child("users").child(currentUser.uid).child("following_count")
//            followingCountRef.runTransactionBlock({ (followingData) -> FIRTransactionResult in
//                
//                
//                let followingCount = followingData.value as? Int ?? 0
//                followingData.value = userToFollow.isFollowed ? followingCount - 1 : followingCount + 1
//                
//                return FIRTransactionResult.success(withValue: followingData)
//            }, andCompletionBlock: { (error, committed, snapshot) in
//                if let error = error {
//                    assertionFailure(error.localizedDescription)
//                }
//                
//                dispatchGroup.leave()
//            })
//            
//            // update followers
//            
//            dispatchGroup.enter()
//            let followersCountRef = dbRef.child("users").child(userToFollow.uid).child("followers_count")
//            followersCountRef.runTransactionBlock({ (followersData) -> FIRTransactionResult in
//                
//                
//                let followersCount = followersData.value as? Int ?? 0
//                followersData.value = userToFollow.isFollowed ? followersCount - 1 : followersCount + 1
//                
//                return FIRTransactionResult.success(withValue: followersData)
//            }, andCompletionBlock: { (error, committed, snapshot) in
//                if let error = error {
//                    assertionFailure(error.localizedDescription)
//                }
//                
//                dispatchGroup.leave()
//            })
//            
//            dispatchGroup.notify(queue: .main, execute: {
//                completion(true)
//            })
//        }
//    }
    
    
    
    
}
