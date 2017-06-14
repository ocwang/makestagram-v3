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
    var selectedUsers = Set<User>()
    
    // MARK: - Subviews
    
    @IBOutlet weak var rhsNavBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rhsNavBarButton.isEnabled = false
        setupTableView()
        
        UserService.followers(for: User.current) { [unowned self] (followers) in
            self.followers = followers
            self.tableView.reloadData()
        }
    }
    
    func setupTableView() {
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
}

extension NewChatViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let destination = segue.destination as? ChatViewController {
            destination.members = Array(selectedUsers)
        }
    }
}

// MARK: - UITableViewDataSource

extension NewChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let follower = followers[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        cell.textLabel?.text = follower.username
        cell.accessoryType = selectedUsers.contains(follower) ? .checkmark : .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NewChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        defer {
            rhsNavBarButton.isEnabled = selectedUsers.count > 0 ? true : false
        }
        
        let follower = followers[indexPath.row]
        if selectedUsers.contains(follower) {
            selectedUsers.remove(follower)
            cell.accessoryType = .none
        } else {
            selectedUsers.insert(follower)
            cell.accessoryType = .checkmark
        }
    }
}
