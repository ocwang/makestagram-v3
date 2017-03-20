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
    
    static func myTimeline(completion: @escaping ([Post]) -> Void) {
        guard let currentUID = User.current?.uid else { return completion([]) }
        
        let ref = MGDBRef.ref(for: .timeline(uid: currentUID))
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
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
        MGDBRef.ref(for: .followers(uid: uid)).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let followersDict = snapshot.value as? [String : Bool] else {
                return completion([])
            }
            
            let followersKeys = Array(followersDict.keys)
            completion(followersKeys)
        })
    }
    
    static func createUser(_ username: String, forUID uid: String, completion: ((Error?) -> Void)? = nil) {
        let ref = MGDBRef.ref(for: .showUser(uid: uid))
        
        let userAttrs: [String : Any] = ["username": username,
                                         "followers_count": 0,
                                         "following_count" : 0,
                                         "posts_count" : 0]
        
        ref.setValue(userAttrs) { (error, ref) in
            completion?(error)
        }
    }
    
    static func isUser(_ uid: String, beingFollowedbyOtherUser otherUID: String, completion: @escaping (Bool) -> Void) {
        let ref = MGDBRef.ref(for: .followers(uid: uid))
        
        ref.queryEqual(toValue: nil, childKey: otherUID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let _ = snapshot.value as? [String : Bool] else {
                return completion(false)
            }
            
            completion(true)
        })
    }
    
    static func showUser(_ user: User, currentUser: User, completion: @escaping (User?) -> Void) {
        let ref = MGDBRef.ref(for: .showUser(uid: user.uid))
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else { return completion(nil) }
            
            guard user.uid != currentUser.uid else { return completion(user) }
            
            isUser(user.uid, beingFollowedbyOtherUser: currentUser.uid, completion: { (isFollowed) in
                user.isFollowed = isFollowed
                completion(user)
            })
        })
    }
    
    static func allUsers(for currentUser: User, completion: @escaping ([User]) -> Void) {
        let ref = MGDBRef.ref(for: .users)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
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
        
        let ref = MGDBRef.ref(for: .default)
        
        let followData: [String : Any?] = ["followers/\(userToFollow.uid)/\(currentUID)" : true,
                                           "following/\(currentUID)/\(userToFollow.uid)" : true]
        
        ref.updateChildValues(followData) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(false)
            }
            
            let dispatchGroup = DispatchGroup()
            
            // update following
            
            dispatchGroup.enter()
            let followingCountRef = MGDBRef.ref(for: .followingCount(uid: currentUID))
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
            let followersCountRef = MGDBRef.ref(for: .followersCount(uid: userToFollow.uid))
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
                
                ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
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
        
        let ref = MGDBRef.ref(for: .default)
        
        let unfollowData: [String : Any?] = ["followers/\(userToUnfollow.uid)/\(currentUID)" : nil,
                                             "following/\(currentUID)/\(userToUnfollow.uid)" : nil]
        
        ref.updateChildValues(unfollowData) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(false)
            }
            
            let dispatchGroup = DispatchGroup()
            
            // update following
            
            dispatchGroup.enter()
            let followingCountRef = MGDBRef.ref(for: .followingCount(uid: currentUID))
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
            let followersCountRef = MGDBRef.ref(for: .followersCount(uid: userToUnfollow.uid))
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

                ref.updateChildValues(unfollowData, withCompletionBlock: { (error, ref) in
                    dispatchGroup.leave()
                })
            })
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(true)
            })
        }
    }
}
