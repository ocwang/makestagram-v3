//
//  HomeViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 3/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Kingfisher

class HomeViewController: UIViewController {

    // MARK: - Properties
    
    var posts = [Post]()
    
    let paginationHelper = MGPaginationHelper()
    
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
        
        setupTableView()
        
        let ref = FIRDatabase.database().reference()
        
        // TODO: temp way of doing this.. auto refresh shouldn't be handled this
        ref.child("timeline").child(User.current.uid).observe(.value, with: { (snapshot) in
            self.paginationHelper.reloadData(completion: { (posts) in
                self.posts = posts
                self.tableView.reloadData()
            })
        })
    }
    
    // MARK: - Initial Setup
    
    func setupTableView() {
        tableView.registerNib(for: PostHeaderCell.self)
        tableView.registerNib(for: PostImageCell.self)
        tableView.registerNib(for: PostActionCell.self)
        tableView.registerNib(for: PostTextCell.self)
        
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
        let post = posts[section]
        return post.likesCount > 0 ? 4 : 3
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section >= posts.count - 1 {
            paginationHelper.paginate(completion: { [unowned self] (posts) in
                self.posts.append(contentsOf: posts)
                self.tableView.reloadData()
            })
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        
        // TODO: consider cleaning this up
        // TODO: try moving this to an enum so it can be reused for home and profile
        switch indexPath.row {
        case 0:
            let cell: PostHeaderCell = tableView.dequeueReusableCell()
            cell.delegate = self
            cell.usernameLabel.text = post.poster?.username ?? "username"
            
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
            
        case 3:
            let cell: PostTextCell = tableView.dequeueReusableCell()
            cell.postTextLabel.text = "\(post.likesCount) likes"
            
            return cell
            
        default:
            fatalError()
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return PostHeaderCell.height
            
        case 1:
            let post = posts[indexPath.section]
            return post.imageHeight
            
        case 2:
            return PostActionCell.height
            
        case 3:
            return PostTextCell.height
            
        default:
            fatalError()
        }
    }
}

extension HomeViewController: PostHeaderCellDelegate {
    func didTapUserHitBoxButton(_ userHitBoxButton: UIButton, on cell: PostHeaderCell) {
        // TODO: abstract this out
        guard let indexPath = tableView.indexPath(for: cell)
            else { return }
        
        let post = posts[indexPath.section]
        
        guard let poster = post.poster
            else { return }
        
        let storyboard = UIStoryboard(type: .profile)
        let profileViewController: ProfileViewController = storyboard.instantiateViewController()
        profileViewController.user = poster
        
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    func didTapOptionsButton(_ optionsButton: UIButton, on cell: PostHeaderCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let poster = posts[indexPath.section].poster
              else { return }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        var alertAction: UIAlertAction
        if poster.uid == User.current.uid {
            alertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                print("delete post")
            }
        } else {
            alertAction = UIAlertAction(title: "Report as Inappropriate", style: .default) { _ in
                print("report post")
            }
        }
        alertController.addAction(alertAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension HomeViewController: PostActionCellDelegate {
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell) {
        
        guard let indexPath = tableView.indexPath(for: cell)
            else { return }
        
        likeButton.isUserInteractionEnabled = false
        let post = posts[indexPath.section]
        
        LikeService.likeOrUnlikePost(post) { [unowned self] (error) in
            defer {
                likeButton.isUserInteractionEnabled = true
            }
            
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                if !post.isLiked {
                    post.likesCount += 1
                } else {
                    post.likesCount -= 1
                }
                
                post.isLiked = !post.isLiked
                // TODO: consider changing this to insert/delete cell for likes?
                self.tableView.reloadData()
            }
        }
    }
}
