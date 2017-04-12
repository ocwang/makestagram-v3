//
//  FIRStorageReference+Post.swift
//  Makestagram
//
//  Created by Chase Wang on 4/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseStorage

extension FIRStorageReference {
    static let dateFormatter = ISO8601DateFormatter()
    
    static func newPostImageReference() -> FIRStorageReference {
        let uid = User.current.uid
        let timestamp = dateFormatter.string(from: Date())
        
        return FIRStorage.storage().reference().child("images/posts/\(uid)/\(timestamp).jpg")
    }
}
