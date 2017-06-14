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
    
    var messages = [Message]()
    
    var chat: Chat?
    
    var members: [User]!
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        senderId = User.current.uid
        senderDisplayName = User.current.username
        
        // remove avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        // setup recieving messages
        
        
        
        
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = Message(content: text)
        
        if let chat = chat, let chatKey = chat.key {
            ChatService.sendMessage(message, forChatKey: chatKey)
        } else {
            ChatService.createFromMessage(message, withMembers: members, completion: { (chat) in
                guard let chat = chat else { return }
                
                self.chat = chat
                
                if let aChat = self.chat, let chatKey = aChat.key {
                    let ref = FIRDatabase.database().reference().child("messages").child(chatKey)
                    
                    ref.observe(.value, with: { (snapshot) in
                        guard let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] else {
                            return
                        }
                        
                        self.messages = snapshots.flatMap(Message.init)
                        self.finishReceivingMessage()
                    })
                }
            })
        }
        
        
        
        
        
        
        
        
        
        // check if chat exists, if new create chat
        
        
//        let itemRef = "asdf" // message.childByAutoId
//        
//        let messageItem = ["senderId" : senderId!,
//                           "senderName" : senderDisplayName,
//                           "text" : text]
        
        // socket should take care of response
        
        JSQSystemSoundPlayer.jsq_playMessageSentAlert()
        
        finishSendingMessage()
    }
}

// MARK: - JSQMessagesCollectionViewDataSource

extension ChatViewController {
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 13), NSForegroundColorAttributeName : UIColor.black]
        let attrStr = NSAttributedString(string: "msg bubble top label", attributes: attributes)
        return attrStr
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 13), NSForegroundColorAttributeName : UIColor.black]
        let attrStr = NSAttributedString(string: "cell top label", attributes: attributes)
        return attrStr
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item].jsqMessageValue
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.sender.uid == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.sender.uid == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        
        return cell
    }
}

extension ChatViewController {
    fileprivate func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    fileprivate func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
}
