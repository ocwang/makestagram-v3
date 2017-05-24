//
//  FollowService.swift
//  Makestagram
//
//  Created by Chase Wang on 3/20/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct FollowService {

    static func isUserFollowed(_ user: User, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let ref = FIRDatabaseReference.toLocation(.followers(uid: user.uid))
        
        ref.queryEqual(toValue: nil, childKey: currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    static func setIsFollowing(_ isFollowing: Bool, fromCurrentUserTo followee: User, success: @escaping (Bool) -> Void) {
        if isFollowing {
            followUser(followee, forCurrentUserWithSuccess: success)
        } else {
            unfollowUser(followee, forCurrentUserWithSuccess: success)
        }
    }
    
    private static func followUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let followData = ["followers/\(user.uid)/\(currentUID)" : true,
                          "following/\(currentUID)/\(user.uid)" : true]
        
        let ref = FIRDatabaseReference.toLocation(.root)
        ref.updateChildValues(followData) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            
            // dispatch group for count
            
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            let followingCountRef = FIRDatabaseReference.toLocation(.followingCount(uid: currentUID))
            followingCountRef.incrementInTransactionBlock { success in
                if !success {
                    assertionFailure("Unable to update following count.")
                }
                
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            let followersCountRef = FIRDatabaseReference.toLocation(.followersCount(uid: user.uid))
            followersCountRef.incrementInTransactionBlock { success in
                if !success {
                    assertionFailure("Unable to update followers count.")
                }
                
                dispatchGroup.leave()
            }

            dispatchGroup.enter()
            UserService.posts(for: user, completion: { (posts) in
                let postKeys = posts.flatMap { $0.key }
                
                var followData = [String : Any]()
                let timelinePostDict = ["poster_uid" : user.uid]
                postKeys.forEach { followData["timeline/\(currentUID)/\($0)"] = timelinePostDict }
                
                ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                    
                    dispatchGroup.leave()
                })
            })
            
            dispatchGroup.notify(queue: .main) {
                success(true)
            }
        }
    }
    
    private static func unfollowUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        // Use NSNull() object instead of nil because updateChildValues expects type [Hashable : Any]
        // http://stackoverflow.com/questions/38462074/using-updatechildvalues-to-delete-from-firebase
        let followData = ["followers/\(user.uid)/\(currentUID)" : NSNull(),
                          "following/\(currentUID)/\(user.uid)" : NSNull()]
        
        let ref = FIRDatabaseReference.toLocation(.root)
        ref.updateChildValues(followData) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            let followingCountRef = FIRDatabaseReference.toLocation(.followingCount(uid: currentUID))
            followingCountRef.decrementInTransactionBlock { success in
                if !success {
                    assertionFailure("Unable to update following count.")
                }
                
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            let followersCountRef = FIRDatabaseReference.toLocation(.followersCount(uid: user.uid))
            followersCountRef.decrementInTransactionBlock { success in
                if !success {
                    assertionFailure("Unable to update followers count.")
                }
                
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            UserService.posts(for: user) { (posts) in
                var unfollowData = [String : Any]()
                let postsKeys = posts.flatMap { $0.key }
                postsKeys.forEach {
                    // Use NSNull() object instead of nil because updateChildValues expects type [Hashable : Any]
                    unfollowData["timeline/\(currentUID)/\($0)"] = NSNull()
                }
                
                ref.updateChildValues(unfollowData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                    
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: .main) {
                success(true)
            }
        }
    }
}
