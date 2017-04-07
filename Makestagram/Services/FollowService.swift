//
//  FollowService.swift
//  Makestagram
//
//  Created by Chase Wang on 3/20/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FollowService {

    static func allFollowersForUser(_ user: User, completion: @escaping ([String]) -> Void) {
        let allFollowersRef = FIRDatabaseReference.toLocation(.followers(uid: user.uid))
        
        allFollowersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let followersDict = snapshot.value as? [String : Bool] else {
                return completion([])
            }
            
            let followersKeys = Array(followersDict.keys)
            completion(followersKeys)
        })
    }
    
    static func isUser(_ user: User, beingFollowedbyOtherUser otherUser: User, completion: @escaping (Bool) -> Void) {
        let ref = FIRDatabaseReference.toLocation(.followers(uid: user.uid))
            
        ref.queryEqual(toValue: nil, childKey: otherUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let _ = snapshot.value as? [String : Bool] else {
                return completion(false)
            }
            
            completion(true)
        })
    }
    
    static func followUser(_ user: User, completion: @escaping (Error?) -> Void) {
        let currentUID = User.current.uid
        
        let ref = FIRDatabaseReference.toLocation(.root)
        
        let followData: [String : Any?] = ["followers/\(user.uid)/\(currentUID)" : true,
                                           "following/\(currentUID)/\(user.uid)" : true]
        
        ref.updateChildValues(followData) { (error, ref) in
            if let error = error {
                return completion(error)
            }
            
            let dispatchGroup = DispatchGroup()
            
            // update following count
            
            dispatchGroup.enter()
            
            let followingCountRef = FIRDatabaseReference.toLocation(.followingCount(uid: currentUID))
            followingCountRef.incrementInTransactionBlock(completion: { (error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                
                dispatchGroup.leave()
            })
            
            // update followers count
            
            dispatchGroup.enter()
            
            let followersCountRef = FIRDatabaseReference.toLocation(.followersCount(uid: user.uid))
            followersCountRef.incrementInTransactionBlock(completion: { (error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            
            PostService.allPosts(for: user, completion: { (posts) in
                var followData = [String : Any]()
                let postsKeys = posts.flatMap { $0.key }
                
                let timelinePostDict: [String : Any] = ["poster_uid" : user.uid]
                postsKeys.forEach { followData["timeline/\(currentUID)/\($0)"] = timelinePostDict }
                
                ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
                    dispatchGroup.leave()
                })
            })
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(nil)
            })
        }
    }
    
    static func unfollowUser(_ user: User, completion: @escaping (Error?) -> Void) {
        let currentUID = User.current.uid
        
        let ref = FIRDatabaseReference.toLocation(.root)
        
        let followData: [String : Any?] = ["followers/\(user.uid)/\(currentUID)" : nil,
                                           "following/\(currentUID)/\(user.uid)" : nil]
        
        ref.updateChildValues(followData) { (error, ref) in
            if let error = error {
                return completion(error)
            }
            
            let dispatchGroup = DispatchGroup()
            
            // update following count
            
            dispatchGroup.enter()
            
            let followingCountRef = FIRDatabaseReference.toLocation(.followingCount(uid: currentUID))
            followingCountRef.decrementInTransactionBlock(completion: { (error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                
                dispatchGroup.leave()
            })
            
            // update followers count
            
            dispatchGroup.enter()
            
            let followersCountRef = FIRDatabaseReference.toLocation(.followersCount(uid: user.uid))
            followersCountRef.decrementInTransactionBlock(completion: { (error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            
            PostService.allPosts(for: user, completion: { (posts) in
                // Type Any? value for dictionary causes 3 warnings, but code will not work without type as Any?
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
                completion(nil)
            })
        }
    }
}
