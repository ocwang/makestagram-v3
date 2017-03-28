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
    
    // MARK: - Subviews
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserService.allUsers(for: User.current) { [unowned self] (users) in
            self.users = users
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource

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

// MARK: - UITableViewDelegate

extension FindFriendsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        // TODO: abstract this out
        let storyboard = UIStoryboard(type: .profile)
        let selectedUser = users[indexPath.row]
        let profileViewController: ProfileViewController = storyboard.instantiateViewController()
        profileViewController.user = selectedUser
        
        navigationController?.pushViewController(profileViewController, animated: true)
    }
}

extension FindFriendsViewController: FindFriendCellDelegate {
    func didTapFollowButton(_ followButton: UIButton, on cell: FindFriendCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        followButton.isUserInteractionEnabled = false
        let user = users[indexPath.row]
        
        var completion = { (error: Error?) in
            defer {
                followButton.isUserInteractionEnabled = true
            }
            
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            
            user.isFollowed = !user.isFollowed
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        if !user.isFollowed {
            FollowService.followUser(user, completion: completion)
        } else {
            FollowService.unfollowUser(user, completion: completion)
        }
    }
}
