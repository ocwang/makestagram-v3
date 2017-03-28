//
//  ProfileViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 3/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    var user: User!
    
    var posts = [Post]()
    
    let timestampFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        return dateFormatter
    }()
    
    // MARK: - Subviews
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        user = user ?? User.current

        setupNavBar()
        setupTableView()
        loadData()
    }
    
    // MARK: - Initial Setup
    
    func setupNavBar() {
        navigationItem.title = user.username
        
        guard user.uid == User.current.uid,
              let vc = navigationController?.childViewControllers.first as? ProfileViewController,
              self == vc
              else { return }
        
        let findFriendsBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_nav_find_friends_black"),
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(findFriendsBarButtonTapped(_:)))
        
        let settingsBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_nav_settings_black"),
                                                style: .plain,
                                                target: self,
                                                action: #selector(settingsBarButtonTapped(_:)))
        
        navigationItem.setLeftBarButton(findFriendsBarButton, animated: false)
        navigationItem.setRightBarButton(settingsBarButton, animated: false)
    }
    
    func setupTableView() {
        tableView.registerNib(for: PostHeaderCell.self)
        tableView.registerNib(for: PostImageCell.self)
        tableView.registerNib(for: PostActionCell.self)
        
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    // TODO: reconsider function name?
    func loadData() {
        UserService.observeUser(user, currentUser: User.current) { (user) in
            guard let user = user else { return }
            
            self.user = user
            
            DispatchQueue.main.async {
                self.navigationItem.title = user.username
                let section = IndexSet(integer: 0)
                self.tableView.reloadSections(section, with: .none)
            }
        }
        
        PostService.allPosts(for: user) { (posts) in
            self.posts = posts
            self.tableView.reloadData()
        }
    }
}

// MARK: - Nav Bar Button Actions

extension ProfileViewController {
    func findFriendsBarButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Constants.Segue.findFriends, sender: self)
    }
    
    func settingsBarButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Constants.Segue.settings, sender: self)
    }
}

// MARK: - TableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section > 0 else {
            let cell: ProfileHeaderCell = tableView.dequeueReusableCell()
            configureProfileHeaderCell(cell)
            cell.delegate = self

            return cell
        }

        // TODO: consider cleaning this up
        // TODO: try moving this to an enum so it can be reused for home and profile
        let post = posts[indexPath.section - 1]
        
        switch indexPath.row {
        case 0:
            let cell: PostHeaderCell = tableView.dequeueReusableCell()
            cell.delegate = self
            cell.usernameLabel.text = user?.username
            
            return cell
            
        case 1:
            let cell: PostImageCell = tableView.dequeueReusableCell()
            let imageURL = URL(string: post.imageURL)
            cell.postImageView.kf.setImage(with: imageURL)
            
            return cell
            
        case 2:
            let cell: PostActionCell = tableView.dequeueReusableCell()
            configureCell(cell, with: post)
            cell.delegate = self
            
            return cell
            
        default:
            fatalError()
        }
    }
    
    func configureProfileHeaderCell(_ cell: ProfileHeaderCell) {
        cell.postsCountLabel.text = String(user.postsCount ?? 0)
        cell.followersCountLabel.text = String(user.followersCount ?? 0)
        cell.followingCountLabel.text = String(user.followingCount ?? 0)
        
        if user.uid == User.current.uid {
            cell.setFollowButton(withTitle: "Edit Profile", isBlue: false)
        } else if user.isFollowed {
            // user is already being followed
            cell.setFollowButton(withTitle: "Following", isBlue: false)
        } else {
            // user is not being followed
            cell.setFollowButton(withTitle: "Follow", isBlue: true)
        }
    }
    
    func configureCell(_ cell: PostActionCell, with post: Post) {
        cell.timeAgoLabel.text = timestampFormatter.string(from: post.creationDate)
        cell.likeButton.isSelected = post.isLiked
        cell.likesCountLabel.text = "\(post.likesCount) likes"
    }
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.section > 0
            else { return 115 }

        switch indexPath.row {
        case 0:
            return PostHeaderCell.height
            
        case 1:
            let post = posts[indexPath.section - 1]
            return post.imageHeight
            
        case 2:
            return PostActionCell.height
            
        default:
            fatalError("Error: unexpected indexPath for \(#line):\(#function)")
        }
    }
}

extension ProfileViewController: PostHeaderCellDelegate {
    func didTapOptionsButton(_ optionsButton: UIButton, on cell: PostHeaderCell) {
        guard let indexPath = tableView.indexPath(for: cell)
              else { return }
        
        _ = posts[indexPath.section - 1]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            print("delete post")
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension ProfileViewController: ProfileHeaderCellDelegate {
    func didTapFollowButton(_ followButton: UIButton, on cell: ProfileHeaderCell) {
        guard user.uid != User.current.uid else {
            // segue to edit profile
            print("segue to rpofile")
            return
        }

        followButton.isUserInteractionEnabled = false
        
        var completion = { (error: Error?) in
            defer {
                followButton.isUserInteractionEnabled = true
            }
            
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
        }

        if !user.isFollowed {
            FollowService.followUser(user, completion: completion)
        } else {
            FollowService.unfollowUser(user, completion: completion)
        }
    }
}

extension ProfileViewController: PostActionCellDelegate {
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell) {
        guard let indexPath = tableView.indexPath(for: cell)
            else { return }
        
        likeButton.isUserInteractionEnabled = false
        let post = posts[indexPath.section - 1]
        
        var completion = { (error: Error?) in
            defer {
                likeButton.isUserInteractionEnabled = true
            }
            
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            
            if !post.isLiked {
                post.likesCount += 1
            } else {
                post.likesCount -= 1
            }
            
            post.likesCount += !post.isLiked ? 1 : -1
            
            post.isLiked = !post.isLiked
            
            guard let cell = self.tableView.cellForRow(at: indexPath) as? PostActionCell
                else { return }
            
            DispatchQueue.main.async {
                self.configureCell(cell, with: post)
            }
        }
        
        if post.isLiked {
            LikeService.deleteLike(for: post, completion: completion)
        } else {
            LikeService.createLike(for: post, completion: completion)
        }
    }
}
