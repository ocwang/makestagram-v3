//
//  LikeService.swift
//  Makestagram
//
//  Created by Chase Wang on 3/20/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase

class LikeService {
    static func isPost(forKey postKey: String, likedByUserforUID uid: String, completion: @escaping (Bool) -> Void) {
        let ref = MGDBRef.ref(for: .isLiked(postKey: postKey))
        
        ref.queryEqual(toValue: nil, childKey: uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let _ = snapshot.value as? [String : Bool] else {
                return completion(false)
            }
            
            completion(true)
        })
    }
    
    // TODO: Ask Dion / Eliel how to approach this?
    
    static func likeOrUnlikePost(_ post: Post, completion: @escaping (Error?) -> Void) {
        guard let postKey = post.key,
              let poster = post.poster else {
                  assertionFailure("Error: post has insufficient data.")
                  return completion(nil)
              }
        
        let updatedLikeValue: Bool? = post.isLiked ? nil : true
        
        let postLikesRef = MGDBRef.ref(for: .likes(postKey: postKey, currentUID: User.current.uid))
        postLikesRef.setValue(updatedLikeValue) { (error, ref) in
            if let error = error {
                return completion(error)
            }
            
            let likesCountRef = MGDBRef.ref(for: .likesCount(posterUID: poster.uid, postKey: postKey))
            
            let transactionBlock = post.isLiked ? FIRDatabaseReference.decrementInTransactionBlock : FIRDatabaseReference.incrementInTransactionBlock
            transactionBlock(likesCountRef)({ (error) in
                completion(error)
            })
        }
    }
}
