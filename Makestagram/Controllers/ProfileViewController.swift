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
    
    enum Section: Int {
        case header
        case posts
    }
    
    var ref: FIRDatabaseReference!
    
    var posts = [Post]()
    
    @IBOutlet weak var tableView: UITableView!
    var user: User!
    
    let timestampFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user == nil {
            user = User.current
        }
        
        if let vc = navigationController?.childViewControllers.first as? ProfileViewController, self == vc {
            let leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_nav_find_friends_black"), style: .plain, target: self, action: #selector(findFriendsBarButtonItemTapped))
            navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
            
            
            // logic to set settings bar button item as well
        }
        navigationItem.title = user.username
        
        PostService.allPosts(forUID: user.uid) { (posts) in
            self.posts = posts
            self.tableView.reloadData()
        }
        
        tableView.registerNib(for: PostHeaderCell.self)
        tableView.registerNib(for: PostImageCell.self)
        tableView.registerNib(for: PostActionCell.self)
        
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    func findFriendsBarButtonItemTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Constants.Segue.findFriends, sender: self)
    }
}

extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section != 0 else {
            let cell: ProfileHeaderCell = tableView.dequeueReusableCell()
            
            cell.postsCountLabel.text = String(user.postsCount ?? 0)
            cell.followersCountLabel.text = String(user.followersCount ?? 0)
            cell.followingCountLabel.text = String(user.followingCount ?? 0)
            
            return cell
        }

        // TODO: consider cleaning this up
        // TODO: try moving this to an enum so it can be reused for home and profile
        let post = posts[indexPath.section - 1]
        
        switch indexPath.row {
        case 0:
            let cell: PostHeaderCell = tableView.dequeueReusableCell()
            cell.usernameLabel.text = user.username
            
            return cell
            
        case 1:
            let cell: PostImageCell = tableView.dequeueReusableCell()
            let imageURL = URL(string: post.imageURL)
            cell.postImageView.kf.setImage(with: imageURL)
            
            return cell
            
        case 2:
            let cell: PostActionCell = tableView.dequeueReusableCell()
            cell.delegate = self
            cell.timeAgoLabel.text = timestampFormatter.string(from: post.creationDate)
            cell.likeButton.isSelected = post.isLiked
            
            return cell
            
        default: fatalError()
        }
    }
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.section > 0
            else { return 115 }

        switch indexPath.row {
        case 0: return PostHeaderCell.height
            
        case 1:
            let post = posts[indexPath.section - 1]
            return post.imageHeight
            
        case 2: return PostActionCell.height
            
        default:
            fatalError("Error: unexpected indexPath for \(#line):\(#function)")
        }
    }
}

extension ProfileViewController: PostActionCellDelegate {
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell) {
        // TODO: make this more reusable
        // TODO: move current user somewhere else
        guard let indexPath = tableView.indexPath(for: cell),
            let uid = User.current?.uid
            else { return }
        
        likeButton.isUserInteractionEnabled = false
        
        let post = posts[indexPath.section - 1]
        PostService.likePost(post) { (error, isLiked, likesCount) in
            defer {
                likeButton.isUserInteractionEnabled = true
            }
            
            guard error == nil else {
                assertionFailure("Error liking post.")
                return
            }
            
            DispatchQueue.main.async {
                post.isLiked = isLiked
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
}
