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
    
    static func isPost(forKey postKey: String, likedByUser user: User, completion: @escaping (Bool) -> Void) {
        let ref = MGDBRef.ref(for: .isLiked(postKey: postKey))
        
        ref.queryEqual(toValue: nil, childKey: user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let _ = snapshot.value as? [String : Bool] else {
                return completion(false)
            }
            
            completion(true)
        })
    }
    
    static func createLike(for post: Post, completion: @escaping (Error?) -> Void) {
        let (postKey, poster) = validatePost(post)
        
        let postLikesRef = MGDBRef.ref(for: .likes(postKey: postKey, currentUID: User.current.uid))
        postLikesRef.setValue(true) { (error, ref) in
            if let error = error {
                return completion(error)
            }
            
            let likesCountRef = MGDBRef.ref(for: .likesCount(posterUID: poster.uid, postKey: postKey))
            likesCountRef.incrementInTransactionBlock(completion: completion)
        }
    }
    
    static func deleteLike(for post: Post, completion: @escaping (Error?) -> Void) {
        let (postKey, poster) = validatePost(post)
        
        let postLikesRef = MGDBRef.ref(for: .likes(postKey: postKey, currentUID: User.current.uid))
        postLikesRef.setValue(nil) { (error, ref) in
            if let error = error {
                return completion(error)
            }
            
            let likesCountRef = MGDBRef.ref(for: .likesCount(posterUID: poster.uid, postKey: postKey))
            likesCountRef.decrementInTransactionBlock(completion: completion)
        }
    }
    
    // MARK: - Private
    
    private static func validatePost(_ post: Post) -> (postKey: String, poster: User) {
        guard let postKey = post.key,
              let poster = post.poster else {
                  preconditionFailure("Error: post has insufficient data.")
              }
        
        return (postKey, poster)
    }
}
