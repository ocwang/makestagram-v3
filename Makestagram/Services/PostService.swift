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
    
    static func createPost(_ post: Post) {
        guard let currentUser = User.current else { return }
        
        let dbRef = MGDBRef.ref(for: .default)
        let newPostRef = MGDBRef.ref(for: .newPost)
        let newPostKey = newPostRef.key
        
        UserService.allFollowers(forUID: currentUser.uid) { (followerKeys) in
            // TODO: removed created_at because don't think you can sort chronologically server-cide...
            // double-check and add back if you can
            // "created_at" : post.creationDate.timeIntervalSince1970
            
            let timelinePostDict: [String : Any] = ["poster_uid" : currentUser.uid]
            var updatedData: [String: Any] = ["timeline/\(currentUser.uid)/\(newPostKey)" : timelinePostDict]
            
            for userKey in followerKeys {
                updatedData["timeline/\(userKey)/\(newPostKey)"] = timelinePostDict
            }
            
            var postDict = post.toDict()
            postDict["likes_count"] = 0
            
            let userDict = currentUser.toDict()
            postDict["poster"] = userDict
            
            updatedData["posts/\(currentUser.uid)/\(newPostKey)"] = postDict
            
            // write dictionary to firebase
            dbRef.updateChildValues(updatedData) { (error, ref) in
                
                // update user's post count
                let postsCountRef = dbRef.child("users").child(currentUser.uid).child("posts_count")
                postsCountRef.runTransactionBlock({ (postsCountData) -> FIRTransactionResult in
                    let postsCount = postsCountData.value as? Int ?? 0
                    postsCountData.value = postsCount + 1
                    
                    return FIRTransactionResult.success(withValue: postsCountData)
                })
            }
        }
    }
    
    static func showPostForKey(_ postKey: String, posterUID: String, completion: @escaping (Post?) -> Void) {
        let ref = MGDBRef.ref(for: .showPost(uid: posterUID, postKey: postKey))
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let post = Post(snapshot: snapshot),
                let postKey = post.key else {
                    return completion(nil)
            }
            
            // TODO: better way to do this
            let currentUID = User.current!.uid
            
            isPost(forKey: postKey, likedByUserforUID: currentUID, completion: { (isLiked) in
                post.isLiked = isLiked
                
                completion(post)
            })
            
        })
    }
    
    static func allPosts(forUID uid: String, completion: @escaping ([Post]) -> Void) {
        let ref = MGDBRef.ref(for: .posts(uid: uid))
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]
                else { return completion([]) }
            
            let dispatchGroup = DispatchGroup()
            
            var posts = [Post]()
            for postSnap in snapshot {
                guard let post = Post(snapshot: postSnap),
                    let postKey = post.key
                    else { continue }
                
                dispatchGroup.enter()
                
                // TODO: better way to do this
                let currentUID = User.current!.uid
                
                isPost(forKey: postKey, likedByUserforUID: currentUID, completion: { (isLiked) in
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
        let ref = MGDBRef.ref(for: .isLiked(postKey: postKey))
        
        ref.queryEqual(toValue: nil, childKey: uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let _ = snapshot.value as? [String : Bool] else {
                return completion(false)
            }
            
            completion(true)
        })
    }
    
    static func likePost(_ post: Post, completion: @escaping (Error?, Bool, Int?) -> Void) {
        // TODO: Anyway to clean this up and move this outside of the service?
        
        guard let postKey = post.key,
            let poster = post.poster,
            let currentUID = User.current?.uid else {
                assertionFailure("Error: post has insufficient data.")
                return completion(nil, post.isLiked, nil)
        }
        
        let newLikesRef = MGDBRef.ref(for: .likes(postKey: postKey, currentUID: currentUID))

        // TODO: change this to be explicit, no logic should be in service classes, move logic to controller
        let likeValue: Bool? = post.isLiked ? nil : true
        
        newLikesRef.setValue(likeValue) { (error, ref) in
            guard error == nil else {
                return completion(error, post.isLiked, nil)
            }

            // update likes count
            
            let likesCountRef = MGDBRef.ref(for: .likesCount(posterUID: poster.uid, postKey: postKey))
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
