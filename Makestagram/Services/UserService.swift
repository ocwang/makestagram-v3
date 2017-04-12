//
//  UserService.swift
//  Makestagram
//
//  Created by Chase Wang on 3/15/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth.FIRUser

struct UserService {
    
    static func allUsers(for currentUser: User, completion: @escaping ([User]) -> Void) {
        let ref = FIRDatabaseReference.toLocation(.users)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allUsers = snapshot.children.allObjects as? [FIRDataSnapshot]
                else { return completion([]) }
            
            var users = [User]()
            let dispatchGroup = DispatchGroup()
            
            for user in allUsers {
                guard let user = User(snapshot: user),
                      user.uid != currentUser.uid
                      else { continue }
                
                dispatchGroup.enter()
                
                FollowService.isUser(user, beingFollowedbyOtherUser: currentUser, completion: { (isFollowed) in
                    user.isFollowed = isFollowed
                    users.append(user)
                    
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(users)
            })
        })
    }
    
//    static func observeUser(_ user: User, currentUser: User, completion: @escaping (User?) -> Void) {
//        let userRef = FIRDatabaseReference.toLocation(.showUser(uid: user.uid))
//        
//        userRef.observe(.value, with: { (snapshot) in
//            guard let user = User(snapshot: snapshot)
//                else { return completion(nil) }
//            
//            guard user.uid != currentUser.uid
//                else { return completion(user) }
//            
//            FollowService.isUser(user, beingFollowedbyOtherUser: currentUser, completion: { (isFollowed) in
//                user.isFollowed = isFollowed
//                completion(user)
//            })
//        })
//    }
    
    static func current(_ firUser: FIRUser, completion: @escaping (User?) -> Void) {
        let ref = FIRDatabaseReference.toLocation(.showUser(uid: firUser.uid))
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            
            completion(user)
        })
    }
    
//    static func show(_ user: User, currentUser: User, completion: @escaping (User?) -> Void) {
//        let ref = MGDatabaseReference.ref(for: .showUser(uid: user.uid))
//        
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let user = User(snapshot: snapshot) else { return completion(nil) }
//            
//            guard user.uid != currentUser.uid else { return completion(user) }
//            
//            FollowService.isUser(user, beingFollowedbyOtherUser: currentUser, completion: { (isFollowed) in
//                user.isFollowed = isFollowed
//                completion(user)
//            })
//        })
//    }
    
    static func create(_ firUser: FIRUser, username: String, completion: @escaping (User?) -> Void) {
        let userAttrs: [String : Any] = ["username": username]
        
        let ref = FIRDatabaseReference.toLocation(.showUser(uid: firUser.uid))
        
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
    
    static func timeline(pageSize: UInt, lastPostKey: String? = nil, completion: @escaping ([Post]) -> Void) {
        let ref = FIRDatabaseReference.toLocation(.timeline(uid: User.current.uid))
        var query = ref.queryOrderedByKey().queryLimited(toLast: pageSize)
        if let lastPostKey = lastPostKey {
            query = query.queryEnding(atValue: lastPostKey)
        }
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]
                else { return completion([]) }
            
            let dispatchGroup = DispatchGroup()
            
            var posts = [Post]()
            for postSnap in snapshot {
                guard let postDict = postSnap.value as? [String : Any],
                    let posterUID = postDict["poster_uid"] as? String
                    else { continue }
                
                dispatchGroup.enter()
                
                PostService.show(forKey: postSnap.key, posterUID: posterUID, completion: { (post) in
                    if let post = post {
                        posts.append(post)
                    }
                    
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                // TODO: better way of ordering... wtf can't do this server side w firebase
                completion(posts.reversed())
            })
        })
    }
    
    static func posts(for user: User, completion: @escaping ([Post]) -> Void) {
        let ref = FIRDatabaseReference.toLocation(.posts(uid: user.uid))
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else {
                return completion([])
            }
            
            let dispatchGroup = DispatchGroup()
            
            let posts: [Post] =
                snapshot
                    .reversed()
                    .flatMap {
                        guard let post = Post(snapshot: $0),
                            let key = post.key
                            else { return nil }
                        
                        dispatchGroup.enter()
                        
                        LikeService.isPost(forKey: key, likedByUser: User.current, completion: { (isLiked) in
                            post.isLiked = isLiked
                            
                            dispatchGroup.leave()
                        })
                        
                        return post
                    }
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(posts)
            })
        })
    }
}


