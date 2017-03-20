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
    
    
    // MARK: - Subviews
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        tableView.tableFooterView = UIView()
        
        UserService.allUsers(for: User.current) { [unowned self] (users) in
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
        let userToFollow = users[indexPath.row]
        
        FollowService.followOrUnfollowUser(userToFollow) { (error) in
            defer {
                followButton.isUserInteractionEnabled = true
            }
            
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            
            userToFollow.isFollowed = !userToFollow.isFollowed
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}
