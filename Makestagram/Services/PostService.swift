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
        let currentUser = User.current
        
        let dbRef = MGDBRef.ref(for: .default)
        let newPostRef = MGDBRef.ref(for: .newPost)
        let newPostKey = newPostRef.key
        
        FollowService.allFollowers(forUID: currentUser.uid) { (followerKeys) in
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
                let postsCountRef = MGDBRef.ref(for: .postCount(uid: currentUser.uid))
                postsCountRef.incrementInTransactionBlock(completion: nil)
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
            LikeService.isPost(forKey: postKey, likedByUserforUID: User.current.uid, completion: { (isLiked) in
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
                
                LikeService.isPost(forKey: postKey, likedByUserforUID: User.current.uid, completion: { (isLiked) in
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
    
}
