//
//  FIRDatabaseReference+Location.swift
//  Makestagram
//
//  Created by Chase Wang on 4/7/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension FIRDatabaseReference {
    enum MGLocation {
        case root
        
        case posts(uid: String)
        case showPost(uid: String, postKey: String)
        case newPost
        case postCount(uid: String)
        
        case users
        case showUser(uid: String)
        case timeline(uid: String)
        
        case followers(uid: String)
        case followingCount(uid: String)
        case followersCount(uid: String)
        
        case likes(postKey: String, currentUID: String)
        case isLiked(postKey: String)
        case likesCount(posterUID: String, postKey: String)
        
        func asDatabaseReference() -> FIRDatabaseReference {
            let root = FIRDatabase.database().reference()
            
            switch self {
            case .root:
                return root
                
            case .posts(let uid):
                return root.child("posts").child(uid)
                
            case let .showPost(uid, postKey):
                return root.child("posts").child(uid).child(postKey)
                
            case .newPost:
                return root.child("posts").childByAutoId()
                
            case .postCount(let uid):
                return root.child("users").child(uid).child("posts_count")
                
            case .users:
                return root.child("users")
                
            case .showUser(let uid):
                return root.child("users").child(uid)
                
            case .timeline(let uid):
                return root.child("timeline").child(uid)
                
            case .followers(let uid):
                return root.child("followers").child(uid)
                
            case .followingCount(let uid):
                return root.child("users").child(uid).child("following_count")
                
            case .followersCount(let uid):
                return root.child("users").child(uid).child("followers_count")
                
            case let .likes(postKey, currentUID):
                return root.child("postLikes").child(postKey).child(currentUID)
                
            case .isLiked(let postKey):
                return root.child("postLikes/\(postKey)")
                
            case let .likesCount(posterUID, postKey):
                return root.child("posts").child(posterUID).child(postKey).child("likes_count")
            }
        }
    }
    
    static func toLocation(_ location: MGLocation) -> FIRDatabaseReference {
        return location.asDatabaseReference()
    }
}
