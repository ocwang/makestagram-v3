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
        
        let followData: [String : Bool] = ["followers/\(user.uid)/\(currentUID)" : true,
                                           "following/\(currentUID)/\(user.uid)" : true]
        
        ref.updateChildValues(followData) { (error, ref) in
            if let error = error {
                return completion(error)
            }
            
            UserService.posts(for: user, completion: { (posts) in
                var followData = [String : Any]()
                let postsKeys = posts.flatMap { $0.key }
                
                let timelinePostDict: [String : Any] = ["poster_uid" : user.uid]
                postsKeys.forEach { followData["timeline/\(currentUID)/\($0)"] = timelinePostDict }
                
                ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
                    completion(nil)
                })
            })
        }
    }
    
    static func unfollowUser(_ user: User, completion: @escaping (Error?) -> Void) {
        let currentUID = User.current.uid
        
        let ref = FIRDatabaseReference.toLocation(.root)
        // Use NSNull() object instead of nil because updateChildValues expects type [Hashable : Any]
        // http://stackoverflow.com/questions/38462074/using-updatechildvalues-to-delete-from-firebase
        let followData: [String : Any] = ["followers/\(user.uid)/\(currentUID)" : NSNull(),
                                           "following/\(currentUID)/\(user.uid)" : NSNull()]
        
        ref.updateChildValues(followData) { (error, ref) in
            if let error = error {
                return completion(error)
            }
            
            UserService.posts(for: user, completion: { (posts) in
                var unfollowData = [String : Any]()
                let postsKeys = posts.flatMap { $0.key }
                postsKeys.forEach {
                    // Use NSNull() object instead of nil because updateChildValues expects type [Hashable : Any]
                    unfollowData["timeline/\(currentUID)/\($0)"] = NSNull()
                }
                
                ref.updateChildValues(unfollowData, withCompletionBlock: { (error, ref) in
                    completion(nil)
                })
            })
        }
    }
}
