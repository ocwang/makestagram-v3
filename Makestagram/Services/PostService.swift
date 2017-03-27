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
        
        FollowService.allFollowersForUser(currentUser) { (followerKeys) in
            let timelinePostDict: [String : Any] = ["poster_uid" : currentUser.uid]
            var updatedData: [String: Any] = ["timeline/\(currentUser.uid)/\(newPostKey)" : timelinePostDict]
            
            for userKey in followerKeys {
                updatedData["timeline/\(userKey)/\(newPostKey)"] = timelinePostDict
            }
            
            var postDict = post.toDict()
            
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
            
            LikeService.isPostForKey(postKey, likedByUser: User.current, completion: { (isLiked) in
                post.isLiked = isLiked
                
                completion(post)
            })
        })
    }
    
    static func allPostsForUser(_ user: User, completion: @escaping ([Post]) -> Void) {
        let ref = MGDBRef.ref(for: .posts(uid: user.uid))
        
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
                
                
                LikeService.isPostForKey(postKey, likedByUser: User.current, completion: { (isLiked) in
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
