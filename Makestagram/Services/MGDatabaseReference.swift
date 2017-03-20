//
//  MGDatabaseRef.swift
//  Makestagram
//
//  Created by Chase Wang on 3/19/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseDatabase

typealias MGDBRef = MGDatabaseReference

enum MGDatabaseReference {
    case posts(uid: String)
    case showPost(uid: String, postKey: String)
    case newPost
    
    case `default`
    
    case users
    case showUser(uid: String)
    case timeline(uid: String)
    case followers(uid: String)
    case followingCount(uid: String)
    case followersCount(uid: String)
    
    case likes(postKey: String, currentUID: String)
    case isLiked(postKey: String)
    case likesCount(posterUID: String, postKey: String)
    
    func asRef(from baseRef: FIRDatabaseReference) -> FIRDatabaseReference {
        switch self {
        case .default:
            return baseRef
            
        case .timeline(let uid):
            return baseRef.child("timeline").child(uid)
            
        case .followers(let uid):
            return baseRef.child("followers").child(uid)
            
        case .newPost:
            return baseRef.child("posts").childByAutoId()
            
        case let .likes(postKey, currentUID):
            return baseRef.child("postLikes").child(postKey).child(currentUID)
            
        case .posts(let uid):
             return baseRef.child("posts").child(uid)
            
        case let .showPost(uid, postKey):
            return baseRef.child("posts").child(uid).child(postKey)
            
        case .isLiked(let postKey):
            return baseRef.child("postLikes/\(postKey)")
            
        case .showUser(let uid):
            return baseRef.child("users").child(uid)
            
        case .users:
            return baseRef.child("users")
            
        case .followingCount(let uid):
            return baseRef.child("users").child(uid).child("following_count")
            
        case .followersCount(let uid):
            return baseRef.child("users").child(uid).child("followers_count")
            
        case let .likesCount(posterUID, postKey):
            return baseRef.child("posts").child(posterUID).child(postKey).child("likes_count")
        }
    }
    
    static func ref(for referenceType: MGDatabaseReference) -> FIRDatabaseReference {
        let baseRef = FIRDatabase.database().reference()
        return referenceType.asRef(from: baseRef)
    }
}
