//
//  UserService.swift
//  Makestagram
//
//  Created by Chase Wang on 3/15/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserService {
    
    static func allUsers(for currentUser: User, completion: @escaping ([User]) -> Void) {
        let ref = MGDBRef.ref(for: .users)
        
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
                
                FollowService.isUser(user.uid, beingFollowedbyOtherUser: currentUser.uid, completion: { (isFollowed) in
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
    
    static func observeUser(_ user: User, currentUser: User, completion: @escaping (User?) -> Void) {
        let userRef = MGDBRef.ref(for: .showUser(uid: user.uid))
        
        userRef.observe(.value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot)
                else { return completion(nil) }
            
            guard user.uid != currentUser.uid
                else { return completion(user) }
            
            FollowService.isUser(user.uid, beingFollowedbyOtherUser: currentUser.uid, completion: { (isFollowed) in
                user.isFollowed = isFollowed
                completion(user)
            })
        })
    }
    
    static func showUser(_ user: User, currentUser: User, completion: @escaping (User?) -> Void) {
        let ref = MGDBRef.ref(for: .showUser(uid: user.uid))
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else { return completion(nil) }
            
            guard user.uid != currentUser.uid else { return completion(user) }
            
            FollowService.isUser(user.uid, beingFollowedbyOtherUser: currentUser.uid, completion: { (isFollowed) in
                user.isFollowed = isFollowed
                completion(user)
            })
        })
    }
    
    static func createUser(_ username: String, forUID uid: String, completion: ((Error?) -> Void)? = nil) {
        let ref = MGDBRef.ref(for: .showUser(uid: uid))
        
        let userAttrs: [String : Any] = ["username": username,
                                         "followers_count": 0,
                                         "following_count" : 0,
                                         "posts_count" : 0]
        
        ref.setValue(userAttrs) { (error, ref) in
            completion?(error)
        }
    }
    
    static func myTimeline(completion: @escaping ([Post]) -> Void) {
        let ref = MGDBRef.ref(for: .timeline(uid: User.current.uid))
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]
                else { return completion([]) }
            
            let dispatchGroup = DispatchGroup()
            
            var posts = [Post]()
            for postSnap in snapshot {
                guard let postDict = postSnap.value as? [String : Any],
                    let posterUID = postDict["poster_uid"] as? String
                    else { continue }
                
                dispatchGroup.enter()
                
                PostService.showPostForKey(postSnap.key, posterUID: posterUID, completion: { (post) in
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
    
}


