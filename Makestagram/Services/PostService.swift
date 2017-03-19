//
//  PostService.swift
//  Makestagram
//
//  Created by Chase Wang on 3/13/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class PostService {
    
    static func createPost(_ post: Post, forUID uid: String) {
        let dbRef = FIRDatabase.database().reference()
        
        let newPostRef = dbRef.child("posts").childByAutoId()
        let newPostKey = newPostRef.key
        
        var postDict = post.toDict()
        postDict["likes_count"] = 0
        
        let updatedUserData: [String : Any] = ["posts/\(uid)/\(newPostKey)" : postDict]
        dbRef.updateChildValues(updatedUserData)
        
        dbRef.updateChildValues(updatedUserData) { (error, ref) in
            
            // update user's post count
            
            let postsCountRef = dbRef.child("users").child(uid).child("posts_count")
            postsCountRef.runTransactionBlock({ (postsCountData) -> FIRTransactionResult in
                let postsCount = postsCountData.value as? Int ?? 0
                postsCountData.value = postsCount + 1
                
                return FIRTransactionResult.success(withValue: postsCountData)
            })
        }
    }
    
    static func allPosts(forUID uid: String, completion: @escaping ([Post]) -> Void) {
        let dbRef = FIRDatabase.database().reference()
        
        _ = dbRef.child("posts").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]
                else { return completion([]) }
            
            let dispatchGroup = DispatchGroup()
            
            var posts = [Post]()
            for postSnap in snapshot {
                guard let post = Post(snapshot: postSnap),
                    let postKey = post.key
                    else { continue }
                
                dispatchGroup.enter()
                
                isPost(forKey: postKey, likedByUserforUID: uid, completion: { (isLiked) in
                    post.isLiked = isLiked
                    posts.append(post)
                    
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: .main, execute: { 
                completion(posts)
            })
        })
    }
    
    static func isPost(forKey postKey: String, likedByUserforUID uid: String, completion: @escaping (Bool) -> Void) {
        let dbRef = FIRDatabase.database().reference()
        
        dbRef.child("postLikes/\(postKey)").queryEqual(toValue: nil, childKey: uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let _ = snapshot.value as? [String : Bool] else {
                return completion(false)
            }
            
            completion(true)
        })
    }
    
    static func likePost(_ post: Post, forUID uid: String, completion: @escaping (Error?, Bool, Int?) -> Void) {
        // TODO: Anyway to clean this up and move this outside of the service?
        guard let postKey = post.key else {
            assertionFailure("Error: post doesn't have a key.")
            return completion(nil, post.isLiked, nil)
        }
        
        let dbRef = FIRDatabase.database().reference()
        
        let newLikesRef = dbRef.child("postLikes").child(postKey).child(uid)
        
        // TODO: change this to be explicit, no logic should be in service classes, move logic to controller
        let likeValue: Bool? = post.isLiked ? nil : true
        
        newLikesRef.setValue(likeValue) { (error, ref) in
            guard error == nil else {
                return completion(error, post.isLiked, nil)
            }

            // update likes count
            
            // TODO: change uid to post user uid... using current user uid temporarily
            
            let likesCountRef = dbRef.child("posts").child(uid).child(postKey).child("likes_count")
            likesCountRef.runTransactionBlock({ (likesData) -> FIRTransactionResult in
                let likesCount = likesData.value as? Int ?? 0
                likesData.value = post.isLiked ? likesCount - 1 : likesCount + 1
                
                return FIRTransactionResult.success(withValue: likesData)
            }, andCompletionBlock: { (error, committed, snapshot) in
                guard error == nil else {
                    assertionFailure("Error updating likes count for post.")
                    return completion(error, !post.isLiked, nil)
                }
                
                guard let likesCount = snapshot?.value as? Int else {
                    assertionFailure("Error reading updated likes count.")
                    return completion(nil, !post.isLiked, nil)
                }
                
                completion(nil, !post.isLiked, likesCount)
            })
        }
    }
}
