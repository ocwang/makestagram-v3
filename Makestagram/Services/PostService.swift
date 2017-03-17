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
        
        let postDict = post.toDict()
        let updatedUserData: [String : Any] = ["posts/\(uid)/\(newPostKey)" : postDict]
        dbRef.updateChildValues(updatedUserData)
    }
}
