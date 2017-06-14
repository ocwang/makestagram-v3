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
    // create new chat
    
    
    static func getForKey(_ chatKey: String, withCompletion completion: @escaping (Chat?) -> Void) {
        let chatRef = FIRDatabase.database().reference().child("chats").child(chatKey)
        chatRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let chat = Chat(snapshot: snapshot)
            completion(chat)
        })
    }
    
    
    static func createFromMessage(_ message: Message, withMembers members: [User], completion: @escaping (Chat?) -> Void) {
        let chatRef = FIRDatabase.database().reference().child("chats").childByAutoId()
        
        let title = members.reduce("") { (acc, cur) -> String in
            if acc.isEmpty {
                return cur.username
            } else {
                return "\(acc), \(cur.username)"
            }
        }
        
        let dictValue = ["title" : title]
        
        chatRef.setValue(dictValue) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            
            sendMessage(message, forChatKey: ref.key, success: { (success) in
                guard success else { return }
                
                getForKey(ref.key, withCompletion: completion)
            })
        }
    }
    
    static func sendMessage(_ message: Message, forChatKey chatKey: String, success: ((Bool) -> Void)? = nil) {
        let messagesRef = FIRDatabase.database().reference().child("messages").child(chatKey).childByAutoId()
        messagesRef.setValue(message.dictValue) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success?(false)
                return
            }
            
            let lastMessage = "\(message.sender.username): \(message.content)"
            let updatedChatValues: [String : Any] = ["lastMessage" : lastMessage, "lastMessageSent" : message.timestamp.timeIntervalSince1970]
            
            let chatRef = FIRDatabase.database().reference().child("chats").child(chatKey)
            chatRef.updateChildValues(updatedChatValues, withCompletionBlock: { (error, ref) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    success?(false)
                    return
                }
                
                success?(true)
            })
        }
    }
    
    
    
    
    
    /*
    
    
    static func createWithMembers(_ members: [User], withCompletion completion: (Chat?) -> Void) {
        
    }
    
    
    static func createWithMessage(_ message: Message, members: [User], completion: (Chat?) -> Void) {
        let chatRef = FIRDatabase.database().reference().child("chats").childByAutoId()
        
        let title = members.reduce("") { (acc, cur) -> String in
            if acc.isEmpty {
                return cur.username
            } else {
                return "\(acc), \(cur.username)"
            }
        }
        
        let dictValue = ["title" : title]
        
        chatRef.setValue(dictValue) { (error, ref) in
            sendMessage(<#T##message: Message##Message#>, for: <#T##Chat#>)
        }
    }
    
    // shouldn't happen until first message is sent
    
    // send message
    
    static func sendMessage(_ message: Message, for chat: Chat) {
        guard let chatKey = chat.key else { return }
        
        let messagesRef = FIRDatabase.database().reference().child("messages").child(chatKey).childByAutoId()
        
        let sender = message.sender
        let userDict = ["username" : sender.username,
                        "uid" : sender.username]
        
        let dict: [String : Any] = ["sender" : userDict,
                                    "content" : message.content,
                                    "timestamp" : 10]
        
        messagesRef.setValue(dict)
        
        
        
        
        let chatRef = FIRDatabase.database().reference().child("chats").child(chatKey)
        
        let lastMessage = "\(sender.username): \(message.content)"
        let updatedChat: [String : Any] = ["lastMessage" : lastMessage, "timestamp" : 10]
        
        chatRef.updateChildValues(updatedChat)
    }
    
    // get all chats of current user
    */
}
