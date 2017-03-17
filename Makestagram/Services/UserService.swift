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
    static func createUser(_ username: String, forUID uid: String, completion: ((Error?) -> Void)? = nil) {
        let dbRef = FIRDatabase.database().reference()
        
        let userAttrs: [String : Any] = ["username": username,
                                         "followers_count": 0,
                                         "following_count" : 0]
        
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
                else { return }
            
            var counter = 0
            var users = [User]()
            
            for user in allUsers {
                guard let user = User(snapshot: user),
                    user.uid != currentUser.uid
                    else { continue }
                
                isUser(user.uid, beingFollowedbyOtherUser: currentUser.uid, completion: { (isFollowed) in
                    user.isFollowed = isFollowed
                    users.append(user)
                    
                    counter += 1
                    if counter == (allUsers.count - 1) {
                        completion(users)
                    }
                })
            }
        })
    }
    
    static func followUser(_ userToFollow: User, currentUser: User, completion: @escaping (Bool) -> Void) {
        let dbRef = FIRDatabase.database().reference()

        let followValue: Bool? = userToFollow.isFollowed ? nil : true
        let followData: [String : Any?] = ["followers/\(userToFollow.uid)/\(currentUser.uid)" : followValue,
                                           "following/\(currentUser.uid)/\(userToFollow.uid)" : followValue]

        dbRef.updateChildValues(followData) { (error, ref) in
            
            // update following
            
            let followingCountRef = dbRef.child("users").child(currentUser.uid).child("following_count")
            followingCountRef.runTransactionBlock({ (followingData) -> FIRTransactionResult in
                let followingCount = followingData.value as? Int ?? 0
                followingData.value = userToFollow.isFollowed ? followingCount - 1 : followingCount + 1
                
                return FIRTransactionResult.success(withValue: followingData)
            }, andCompletionBlock: { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
            
            // update followers
            
            let followersCountRef = dbRef.child("users").child(userToFollow.uid).child("followers_count")
            followersCountRef.runTransactionBlock({ (followersData) -> FIRTransactionResult in
                let followersCount = followersData.value as? Int ?? 0
                followersData.value = userToFollow.isFollowed ? followersCount - 1 : followersCount + 1
                
                return FIRTransactionResult.success(withValue: followersData)
            }, andCompletionBlock: { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
            
            completion(error == nil)
        }
    }
}
