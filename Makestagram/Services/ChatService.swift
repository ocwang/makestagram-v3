//
//  ChatService.swift
//  Makestagram
//
//  Created by Chase Wang on 6/11/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct ChatService {
    
    static func checkForExistingChat(with user: User, completion: @escaping (Chat?) -> Void) {
        let members = [user, User.current]
        let hashValue = Chat.hash(forMembers: members)
        
        let chatRef = FIRDatabase.database().reference().child("chats").child(User.current.uid)
        let query = chatRef.queryOrdered(byChild: "memberHash").queryEqual(toValue: hashValue)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let chatSnap = snapshot.children.allObjects.first as? FIRDataSnapshot,
                let chat = Chat(snapshot: chatSnap)
                else { return completion(nil) }
            
            completion(chat)
        })
    }
    
    static func get(forKey chatKey: String, withCompletion completion: @escaping (Chat?) -> Void) {
        let chatRef = FIRDatabase.database().reference().child("chats").child(User.current.uid).child(chatKey)
        chatRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let chat = Chat(snapshot: snapshot)
            completion(chat)
        })
    }
    
    static func create(from message: Message, with chat: Chat, completion: @escaping (Chat?) -> Void) {
        
        // set chat
        
        var membersDict = [String : Bool]()
        for uid in chat.memberUIDs {
            membersDict[uid] = true
        }
        
        let lastMessage = "\(message.sender.username): \(message.content)"
        let lastMessageSent = message.timestamp.timeIntervalSince1970
        
        let chatDict: [String : Any] = ["title" : chat.title,
                                        "memberHash" : chat.memberHash,
                                        "members" : membersDict,
                                        "lastMessage" : lastMessage,
                                        "lastMessageSent" : lastMessageSent]
        
        let chatRef = FIRDatabase.database().reference().child("chats").child(User.current.uid).childByAutoId()
        let chatKey = chatRef.key
        
        var multiUpdateValue = [String : Any]()
        
        for uid in chat.memberUIDs {
            multiUpdateValue["chats/\(uid)/\(chatRef.key)"] = chatDict
        }
        
        // set message
        
        let messagesRef = FIRDatabase.database().reference().child("messages").child(chatKey).childByAutoId()
        let messageKey = messagesRef.key
        
        multiUpdateValue["messages/\(chatKey)/\(messageKey)"] = message.dictValue
            
        let rootRef = FIRDatabase.database().reference()
        rootRef.updateChildValues(multiUpdateValue) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            
            get(forKey: chatRef.key, withCompletion: { chat in
                completion(chat)
            })
        }
    }
    
    static func sendMessage(_ message: Message, for chat: Chat, success: ((Bool) -> Void)? = nil) {
        guard let chatKey = chat.key else {
            success?(false)
            return
        }
        
        var multiUpdateValue = [String : Any]()

        // update chat
        
        for uid in chat.memberUIDs {
            let lastMessage = "\(message.sender.username): \(message.content)"
            multiUpdateValue["chats/\(uid)/\(chatKey)/lastMessage"] = lastMessage
            multiUpdateValue["chats/\(uid)/\(chatKey)/lastMessageSent"] = message.timestamp.timeIntervalSince1970
        }
        
        // new message
        
        let messagesRef = FIRDatabase.database().reference().child("messages").child(chatKey).childByAutoId()
        let messageKey = messagesRef.key
        multiUpdateValue["messages/\(chatKey)/\(messageKey)"] = message.dictValue
        
        let rootRef = FIRDatabase.database().reference()
        rootRef.updateChildValues(multiUpdateValue, withCompletionBlock: { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success?(false)
                return
            }
            
            success?(true)
        })
    }
    
    static func observeMessages(forChatKey chatKey: String, completion: @escaping (FIRDatabaseReference, Message?) -> Void) -> FIRDatabaseHandle {
        let messagesRef = FIRDatabase.database().reference().child("messages").child(chatKey)
        let recentQuery = messagesRef.queryLimited(toLast: 25)
        
        return recentQuery.observe(.childAdded, with: { snapshot in
            guard let message = Message(snapshot: snapshot) else {
                return completion(messagesRef, nil)
            }
            
            completion(messagesRef, message)
        })
    }
}
