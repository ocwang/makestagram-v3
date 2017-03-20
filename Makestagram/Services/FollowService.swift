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

    static func allFollowers(forUID uid: String, completion: @escaping ([String]) -> Void) {
        let allFollowersRef = MGDBRef.ref(for: .followers(uid: uid))
        
        allFollowersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let followersDict = snapshot.value as? [String : Bool] else {
                return completion([])
            }
            
            let followersKeys = Array(followersDict.keys)
            completion(followersKeys)
        })
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
    
    // TODO: Ask Dion / Eliel how to approach this?
    
    static func followOrUnfollowUser(_ user: User, completion: @escaping (Error?) -> Void) {
        guard let currentUID = User.current?.uid else {
            assertionFailure("Error: current user doesn't exist.")
            return completion(nil)
        }
        
        let ref = MGDBRef.ref(for: .default)
        
        let updatedFollowValue: Bool? = user.isFollowed ? nil : true
        
        let followData: [String : Any?] = ["followers/\(user.uid)/\(currentUID)" : updatedFollowValue,
                                           "following/\(currentUID)/\(user.uid)" : updatedFollowValue]
        
        ref.updateChildValues(followData) { (error, ref) in
            if let error = error {
                return completion(error)
            }
            
            let transactionBlock = user.isFollowed ? FIRDatabaseReference.decrementInTransactionBlock : FIRDatabaseReference.incrementInTransactionBlock
            let dispatchGroup = DispatchGroup()
            
            // update following count
            
            dispatchGroup.enter()
            
            let followingCountRef = MGDBRef.ref(for: .followingCount(uid: currentUID))
            transactionBlock(followingCountRef)({ (error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                
                dispatchGroup.leave()
            })
            
            // update followers count
            
            dispatchGroup.enter()
            
            let followersCountRef = MGDBRef.ref(for: .followersCount(uid: user.uid))
            transactionBlock(followersCountRef)({ (error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                
                dispatchGroup.leave()
            })
            
            // get user and fetch their posts.. and add each one from timeline
            // fetching when a post is liked for each user!!! crazy... how can we make this better
            
            dispatchGroup.enter()
            
            if !user.isFollowed {
                PostService.allPosts(forUID: user.uid, completion: { (posts) in
                    
                    var followData = [String : Any?]()
                    let postsKeys = posts.flatMap { $0.key }
                    
                    let timelinePostDict: [String : Any] = ["poster_uid" : user.uid]
                    postsKeys.forEach { followData["timeline/\(currentUID)/\($0)"] = timelinePostDict }
                    
                    ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
                        dispatchGroup.leave()
                    })
                })
            } else {
                PostService.allPosts(forUID: user.uid, completion: { (posts) in
                    
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
            }

            /*  This code is not the same as above... why???
             
            PostService.allPosts(forUID: user.uid, completion: { (posts) in
                var updatedFollowData = [String : Any?]()
                let postsKeys = posts.flatMap { $0.key }
                
                if !user.isFollowed {
                    let timelinePostDict: [String : Any] = ["poster_uid" : user.uid]
                    postsKeys.forEach { updatedFollowData["timeline/\(currentUID)/\($0)"] = timelinePostDict }
                } else {
                    // nil must be cast as Any? otherwise dictionary will not be set
                    // http://stackoverflow.com/questions/26544573/how-to-add-nil-value-to-swift-dictionary
                    
                    postsKeys.forEach { updatedFollowData["timeline/\(currentUID)/\($0)"] = nil as Any? }
                }
                
                ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
                    dispatchGroup.leave()
                })
            })
 
             */
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(nil)
            })
        }
    }
}
