//
//  PostService.swift
//  Makestagram
//
//  Created by Chase Wang on 3/13/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage.FIRStorageReference

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
        
        UserService.followers(for: currentUser) { (followerUIDs) in
            let timelinePostDict = ["poster_uid" : currentUser.uid]
            
            var updatedData = ["posts/\(currentUser.uid)/\(newPostKey)" : newPost.dictValue,
                               "timeline/\(currentUser.uid)/\(newPostKey)" : timelinePostDict]
            
            for uid in followerUIDs {
                updatedData["timeline/\(uid)/\(newPostKey)"] = timelinePostDict
            }
            
            dbRef.updateChildValues(updatedData)
        }
    }
    
    static func show(forKey postKey: String, posterUID: String, completion: @escaping (Post?) -> Void) {
        let ref = FIRDatabaseReference.toLocation(.showPost(uid: posterUID, postKey: postKey))
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let post = Post(snapshot: snapshot) else {
                return completion(nil)
            }
            
            LikeService.isPostLiked(post) { (isLiked) in
                post.isLiked = isLiked
                completion(post)
            }
        })
    }
}
