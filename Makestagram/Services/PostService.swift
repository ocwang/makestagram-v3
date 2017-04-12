//
//  PostService.swift
//  Makestagram
//
//  Created by Chase Wang on 3/13/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

struct PostService {
    
    static func create(for image: UIImage) {
        let imageRef = FIRStorageReference.newPostImageReference()
        
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            
            let height = image.aspectHeight
            let urlString = downloadURL.absoluteString
            create(forURLString: urlString, aspectHeight: height)
        }
    }
    
    private static func create(forURLString urlString: String, aspectHeight: CGFloat) {
        let currentUser = User.current
        let newPost = Post(imageURL: urlString, imageHeight: aspectHeight)
        
        let dbRef = FIRDatabaseReference.toLocation(.root)
        let newPostRef = FIRDatabaseReference.toLocation(.newPost)
        let newPostKey = newPostRef.key
        
        FollowService.allFollowersForUser(currentUser) { (followerKeys) in
            let timelinePostDict: [String : Any] = ["poster_uid" : currentUser.uid]
            var updatedData: [String: Any] = ["timeline/\(currentUser.uid)/\(newPostKey)" : timelinePostDict]
            
            for userKey in followerKeys {
                updatedData["timeline/\(userKey)/\(newPostKey)"] = timelinePostDict
            }
            
            var postDict = newPost.dictValue
            
            let userDict = currentUser.toDict()
            postDict["poster"] = userDict
            
            updatedData["posts/\(currentUser.uid)/\(newPostKey)"] = postDict
            
            dbRef.updateChildValues(updatedData)
        }
    }
    
    static func show(forKey postKey: String, posterUID: String, completion: @escaping (Post?) -> Void) {
        let ref = FIRDatabaseReference.toLocation(.showPost(uid: posterUID, postKey: postKey))
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let post = Post(snapshot: snapshot),
                let postKey = post.key else {
                    return completion(nil)
            }
            
            LikeService.isPost(forKey: postKey, likedByUser: User.current, completion: { (isLiked) in
                post.isLiked = isLiked
                
                completion(post)
            })
        })
    }
}
