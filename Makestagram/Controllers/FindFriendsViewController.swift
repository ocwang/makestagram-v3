//
//  FindFriendsViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 3/15/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FindFriendsViewController: UIViewController {
    
    // MARK: - Properties
    
    var users = [User]()
    
    var ref: FIRDatabaseReference!
    
    var currentUser: User!
    
    // MARK: - Subviews
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        if let user = User.current {
            currentUser = user
        }
        
        tableView.tableFooterView = UIView()
        
        UserService.allUsers(for: currentUser) { [unowned self] (users) in
            self.users = users
            self.tableView.reloadData()
        }
    }
}

extension FindFriendsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FindFriendCell = tableView.dequeueReusableCell()
        cell.delegate = self
        configure(cell: cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configure(cell: FindFriendCell, atIndexPath indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        cell.usernameLabel.text = user.username
        cell.followButton.isSelected = user.isFollowed
    }
}

extension FindFriendsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        // TODO: segue to user profile
    }
}

extension FindFriendsViewController: FindFriendCellDelegate {
    func didTapFollowButton(_ followButton: UIButton, on cell: FindFriendCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        followButton.isUserInteractionEnabled = false
        let userToFollow = users[indexPath.row]
        
        UserService.followUser(userToFollow, currentUser: currentUser) { [unowned self] (success) in
            UserService.showUser(userToFollow, currentUser: self.currentUser, completion: { [unowned self] (updatedUser) in
                defer {
                    followButton.isUserInteractionEnabled = true
                }
                
                guard let updatedUser = updatedUser else {
                    assertionFailure("Error fetching updated user.")
                    return
                }

                DispatchQueue.main.async {
                    self.users[indexPath.row] = updatedUser
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            })
        }
    }
}
