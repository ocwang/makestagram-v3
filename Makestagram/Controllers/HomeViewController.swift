//
//  HomeViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 3/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Kingfisher

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var ref: FIRDatabaseReference!
    
    var posts = [Post]()
    
    let timestampFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        let uid = User.current!.uid
        
        PostService.allPosts(forUID: uid) { (posts) in
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
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        
        // TODO: clean this up
        switch indexPath.row {
        case 0:
            let cell: PostHeaderCell = tableView.dequeueReusableCell()
            cell.usernameLabel.text = "ocwang"
            
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

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0: return PostHeaderCell.height
        case 1:
            let post = posts[indexPath.section]
            return post.imageHeight
            
        case 2: return PostActionCell.height
        default: fatalError()
        }
    }
}

extension HomeViewController: PostActionCellDelegate {
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell) {
        
        // TODO: move current user somewhere else
        guard let indexPath = tableView.indexPath(for: cell),
            let uid = User.current?.uid
            else { return }
        
        likeButton.isUserInteractionEnabled = false
        
        let post = posts[indexPath.section]
        PostService.likePost(post, forUID: uid) { (error, isLiked, likesCount) in
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
