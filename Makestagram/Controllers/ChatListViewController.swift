//
//  ChatListViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 6/6/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ChatListViewController: UIViewController {
    
    // MARK: - Properties

    var chats = [Chat]()
    var userChatsHandle: FIRDatabaseHandle = 0
    var userChatsRef: FIRDatabaseReference?
    
    // MARK: - Subviews
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        userChatsHandle = UserService.observeChats { [weak self] (ref, chats) in
            self?.userChatsRef = ref
            self?.chats = chats
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    deinit {
        userChatsRef?.removeObserver(withHandle: userChatsHandle)
    }
    
    func setupTableView() {
        tableView.rowHeight = ChatListCell.height
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
    }

    // MARK: - IBActions
    
    @IBAction func dismissButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatListCell = tableView.dequeueReusableCell()
        
        let chat = chats[indexPath.row]
        cell.titleLabel.text = chat.title
        cell.lastMessageLabel.text = chat.lastMessage
        
        return cell
    }
}

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toChat", sender: self)
    }
}

// MARK: - Navigation

extension ChatListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "toChat",
            let destination = segue.destination as? ChatViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            
            destination.chat = chats[indexPath.row]
        }
    }
    
    @IBAction func unwindToChatListViewController(segue: UIStoryboardSegue) {
        
    }
}
