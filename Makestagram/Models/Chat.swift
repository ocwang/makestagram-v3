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
    
    // MARK: - Class Methods
    
    static func hash(forMembers members: [User]) -> String {
        guard members.count == 2 else {
            fatalError("There must be two members to compute member hash.")
        }
        
        let firstMember = members[0]
        let secondMember = members[1]
        
        // XOR operation is commutative, order of members doesn't matter
        // https://useyourloaf.com/blog/swift-hashable/
        let memberHash = String(firstMember.uid.hashValue ^ secondMember.uid.hashValue)
        return memberHash
    }
    
    // MARK - Properties
    
    var key: String?
    let title: String
    let memberHash: String
    let memberUIDs: [String]
    var lastMessage: String?
    var lastMessageSent: Date?
    
    // MARK: - Init
    
    init(members: [User]){
        assert(members.count == 2, "There must be two members in a chat.")
        
        self.title = members.reduce("") { (acc, cur) -> String in
            return acc.isEmpty ? cur.username : "\(acc), \(cur.username)"
        }
        self.memberHash = Chat.hash(forMembers: members)
        self.memberUIDs = members.map { $0.uid }
    }
    
    init?(snapshot: FIRDataSnapshot) {
        guard !snapshot.key.isEmpty,
            let dict = snapshot.value as? [String : Any],
            let title = dict["title"] as? String,
            let memberHash = dict["memberHash"] as? String,
            let membersDict = dict["members"] as? [String : Bool],
            let lastMessage = dict["lastMessage"] as? String,
            let lastMessageSent = dict["lastMessageSent"] as? TimeInterval
            else { return nil }
        
        self.key = snapshot.key
        self.title = title
        self.memberHash = memberHash
        self.memberUIDs = Array(membersDict.keys)
        self.lastMessage = lastMessage
        self.lastMessageSent = Date(timeIntervalSince1970: lastMessageSent)
    }
}




