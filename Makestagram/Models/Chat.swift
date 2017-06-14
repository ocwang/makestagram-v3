//
//  Chat.swift
//  Makestagram
//
//  Created by Chase Wang on 6/11/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseDatabase.FIRDataSnapshot

class Chat {
    var key: String?
    let title: String
    var lastMessage: String
    var lastMessageSent: Date
    
    init?(snapshot: FIRDataSnapshot) {
        guard !snapshot.key.isEmpty,
            let dict = snapshot.value as? [String : Any],
            let title = dict["title"] as? String,
            let lastMessage = dict["lastMessage"] as? String,
            let lastMessageSent = dict["lastMessageSent"] as? TimeInterval
            else { return nil }
        
        self.key = snapshot.key
        self.title = title
        self.lastMessage = lastMessage
        self.lastMessageSent = Date(timeIntervalSince1970: lastMessageSent)
    }
    
    init(members: [User], message: Message) {
        self.title = members.reduce("") { (acc, cur) -> String in
            return acc.isEmpty ? cur.username : ", \(cur.username)"
        }
        self.lastMessage = "\(message.sender.username): \(message.content)"
        self.lastMessageSent = message.timestamp
    }
}




