//
//  Message.swift
//  Makestagram
//
//  Created by Chase Wang on 6/11/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

// will this subclass other message class?

import JSQMessagesViewController.JSQMessage

class Message {
    let key: String
    let sender: User
    let content: String
    let timestamp: Date
    
    var jsqMessageValue: JSQMessage {
        return JSQMessage(senderId: sender.uid,
                          senderDisplayName: sender.username,
                          date: timestamp,
                          text: content)
    }
    
    
    var dictValue: [String : Any] {
        let userDict = ["username" : sender.username,
                        "uid" : sender.uid]
        
        return ["sender" : userDict,
                "content" : content,
                "timestamp" : timestamp.timeIntervalSince1970]
    }
    
    // MARK: - Init
    
    init?(snapshot: FIRDataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let content = dict["content"] as? String,
            let timestamp = dict["timestamp"] as? TimeInterval,
            let userDict = dict["sender"] as? [String : Any],
            let uid = userDict["uid"] as? String,
            let username = userDict["username"] as? String
            else { return nil }
        
        self.key = snapshot.key
        self.content = content
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        self.sender = User(uid: uid, username: username)
    }
    
    // will we need to store the entire user with the message?
    
    init(content: String) {
        self.key = "asdf" // gen new childId for msg
        self.content = content
        self.timestamp = Date()
        self.sender = User.current
    }
}
