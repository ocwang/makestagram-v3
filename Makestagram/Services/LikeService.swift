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
    
    static func isPost(_ post: Post, likedByUser user: User, completion: @escaping (Bool) -> Void) {
        guard let postKey = post.key else {
            assertionFailure("Error: post must have key.")
            return completion(false)
        }
        
        let ref = FIRDatabaseReference.toLocation(.isLiked(postKey: postKey))
        ref.queryEqual(toValue: nil, childKey: user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    static func setIsLiked(_ isLiked: Bool, for post: Post, success: @escaping (Bool) -> Void) {
        if isLiked {
            create(for: post, success: success)
        } else {
            delete(for: post, success: success)
        }
    }
    
    private static func create(for post: Post, success: @escaping (Bool) -> Void) {
        let (postKey, poster) = validatePost(post)
        
        let postLikesRef = FIRDatabaseReference.toLocation(.likes(postKey: postKey, currentUID: User.current.uid))
        postLikesRef.setValue(true) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            
            let likesCountRef = FIRDatabaseReference.toLocation(.likesCount(posterUID: poster.uid, postKey: postKey))
            likesCountRef.incrementInTransactionBlock(success: success)
        }
    }
    
    private static func delete(for post: Post, success: @escaping (Bool) -> Void) {
        let (postKey, poster) = validatePost(post)
        
        let postLikesRef = FIRDatabaseReference.toLocation(.likes(postKey: postKey, currentUID: User.current.uid))
        postLikesRef.setValue(nil) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            
            let likesCountRef = FIRDatabaseReference.toLocation(.likesCount(posterUID: poster.uid, postKey: postKey))
            likesCountRef.decrementInTransactionBlock(success: success)
        }
    }
    
    // MARK: - Private
    
    private static func validatePost(_ post: Post) -> (postKey: String, poster: User) {
        guard let postKey = post.key else {
                  preconditionFailure("Error: post has insufficient data.")
              }
        
        return (postKey, post.poster)
    }
}
