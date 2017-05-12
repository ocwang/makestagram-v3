//
//  Post.swift
//  Makestagram
//
//  Created by Chase Wang on 3/12/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseDatabase.FIRDataSnapshot

class Post: MGKeyed {
    
    // MARK: - Properties
    
    var key: String?
    let imageURL: String
    let imageHeight: CGFloat
    let creationDate: Date
    var likesCount: Int
    var isLiked = false
    
    let poster: User
    
    var dictValue: [String : Any] {
        let createdAgo = creationDate.timeIntervalSince1970
        let userDict = ["uid" : poster.uid,
                        "username" : poster.username]
        
        return ["image_url" : imageURL,
                "image_height" : imageHeight,
                "created_at" : createdAgo,
                "likes_count" : likesCount,
                "poster" : userDict]
    }
    
    // MARK: - Init
    
    init?(snapshot: FIRDataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
              let imageURL = dict["image_url"] as? String,
              let imageHeight = dict["image_height"] as? CGFloat,
              let createdAtTimeInterval = dict["created_at"] as? TimeInterval,
              let likesCount = dict["likes_count"] as? Int,
              let userDict = dict["poster"] as? [String : Any],
              let uid = userDict["uid"] as? String,
              let username = userDict["username"] as? String
              else { return nil }
        
        self.key = snapshot.key
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.creationDate = Date(timeIntervalSince1970: createdAtTimeInterval)
        self.likesCount = likesCount
        self.poster = User(uid: uid, username: username)
    }

    init(imageURL: String, imageHeight: CGFloat) {
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.creationDate = Date()
        self.poster = User.current
        self.likesCount = 0
    }
}
