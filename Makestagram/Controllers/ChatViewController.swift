//
//  ChatViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 6/6/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    
    // MARK: - Properties
    
    var chat: Chat!
    var messages = [Message]()
    
    var messagesHandle: FIRDatabaseHandle = 0
    var messagesRef: FIRDatabaseReference?
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = {
        guard let bubbleImageFactory = JSQMessagesBubbleImageFactory() else {
            fatalError("Error creating bubble image factory.")
        }
        
        let color = UIColor.jsq_messageBubbleBlue()
        return bubbleImageFactory.outgoingMessagesBubbleImage(with: color)

    }()
    
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = {
        guard let bubbleImageFactory = JSQMessagesBubbleImageFactory() else {
            fatalError("Error creating bubble image factory.")
        }
        
        let color = UIColor.jsq_messageBubbleLightGray()
        return bubbleImageFactory.incomingMessagesBubbleImage(with: color)
    }()
    
    // MARK: - VC Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupJSQMessagesViewController()
        tryObservingMessages()
        
    }
    
    deinit {
        messagesRef?.removeObserver(withHandle: messagesHandle)
    }
    
    // MARK: - IBActions
    
    // TODO: rethink unwind / swipe back from different view controllers
    @IBAction func unwindToChatList(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "unwindToChatList", sender: self)
    }
}

// MARK: - Setup

extension ChatViewController {
    func setupJSQMessagesViewController() {
        senderId = User.current.uid
        senderDisplayName = User.current.username
        title = chat.title
        
        // remove attachment button
        inputToolbar.contentView.leftBarButtonItem = nil
        
        // remove avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    // TODO: change to childAdded
    func tryObservingMessages() {
        guard let chatKey = chat?.key else { return }
        
        messagesHandle = ChatService.observeMessages(forChatKey: chatKey, completion: { [weak self] (ref, message) in
            self?.messagesRef = ref
            
            if let message = message {
                self?.messages.append(message)
                self?.finishReceivingMessage()
            }
        })
    }
}

// MARK: - Send Message

extension ChatViewController {
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = Message(content: text)
        sendMessage(message)
        finishSendingMessage()
        
        JSQSystemSoundPlayer.jsq_playMessageSentAlert()
    }
    
    func sendMessage(_ message: Message) {
        if chat?.key == nil {
            ChatService.create(from: message, with: chat, completion: { [weak self] chat in
                guard let chat = chat else { return }
                
                self?.chat = chat
                
                self?.tryObservingMessages()
            })
        } else {
            ChatService.sendMessage(message, for: chat)
        }
    }
}

// MARK: - JSQMessagesCollectionViewDataSource

extension ChatViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item].jsqMessageValue
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        let sender = message.sender
        
        if sender.uid == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.item]
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView?.textColor = (message.sender.uid == senderId) ? .white : .black
        
        return cell
    }
}
