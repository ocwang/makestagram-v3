//
//  NewChatViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 6/6/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class NewChatViewController: UIViewController {

    // MARK: - Properties
    
    var followers = [User]()
    var selectedUser: User?
    var existingChat: Chat?
    
    // MARK: - Subviews
    
    @IBOutlet weak var rhsNavBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rhsNavBarButton.isEnabled = false
        setupTableView()
        
        UserService.followers(for: User.current) { [weak self] (followers) in
            self?.followers = followers
            self?.tableView.reloadData()
        }
    }
    
    func setupTableView() {
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - IBActions
    
    @IBAction func nextButtonTapped(_ sender: UIBarButtonItem) {
        guard let selectedUser = selectedUser else { return }
        
        sender.isEnabled = false
        ChatService.checkForExistingChat(with: selectedUser) { (chat) in
            sender.isEnabled = true
            self.existingChat = chat
            
            self.performSegue(withIdentifier: "toChat", sender: self)
        }
    }
}

// MARK: - Navigation

extension NewChatViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "toChat", let destination = segue.destination as? ChatViewController, let selectedUser = selectedUser {
            let members = [selectedUser, User.current]
            destination.chat = existingChat ?? Chat(members: members)
        }
    }
}

// MARK: - UITableViewDataSource

extension NewChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewChatUserCell = tableView.dequeueReusableCell()
        configureCell(cell, at: indexPath)
        
        return cell
    }
    
    func configureCell(_ cell: NewChatUserCell, at indexPath: IndexPath) {
        let follower = followers[indexPath.row]
        cell.textLabel?.text = follower.username
        
        if let selectedUser = selectedUser, selectedUser.uid == follower.uid {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
}

// MARK: - UITableViewDelegate

extension NewChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        selectedUser = followers[indexPath.row]
        cell.accessoryType = .checkmark
        
        rhsNavBarButton.isEnabled = selectedUser != nil ? true : false
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        cell.accessoryType = .none
    }
}
