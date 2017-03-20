//
//  User.swift
//  Makestagram
//
//  Created by Chase Wang on 3/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User: NSObject {
    
    // MARK: - Singleton
    
    private static var _current: User?
    
    static var current: User {
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        
        return currentUser
    }
    
    // MARK: - Class Methods
    
    class func setCurrentUser(_ user: User, archiveData: Bool) {
        if archiveData {
            // save current user object in user defaults
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
        }

        _current = user
    }
    
    // MARK: - Properties
    
    let uid: String
    let username: String
    var followersCount: Int?
    var followingCount: Int?
    var postsCount: Int?
    
    
    // TODO: verify putting this here is a good decision
    // find a better way?
    var isFollowed = false
    
    // MARK: - Init
    
    init?(snapshot: FIRDataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String,
            let followersCount = dict["followers_count"] as? Int,
            let followingCount = dict["following_count"] as? Int,
            let postsCount = dict["posts_count"] as? Int
            else { return nil }
        
        self.uid = snapshot.key
        self.username = username
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.postsCount = postsCount
        
        super.init()
    }
    
    init(uid: String, username: String) {
        self.uid = uid
        self.username = username
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: Constants.UserDefaults.uid) as? String,
            let username = aDecoder.decodeObject(forKey: Constants.UserDefaults.username) as? String
            else { return nil }
        
        self.uid = uid
        self.username = username
    }
    
    func toDict() -> [String : Any] {
        return ["uid" : uid, "username" : username]
    }
}

extension User: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: Constants.UserDefaults.uid)
        aCoder.encode(username, forKey: Constants.UserDefaults.username)
        
        // TODO: encode other info?
    }
}
