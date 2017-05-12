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
    
    let paginationHelper = MGPaginationHelper<Post>(makeAPIRequest: UserService.timeline)
    
    let timestampFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        return dateFormatter
    }()
    
    // MARK: - Subviews
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        loadData()
    }
    
    // MARK: - Initial Setup
    
    func setupTableView() {
        tableView.registerNib(for: PostHeaderCell.self)
        tableView.registerNib(for: PostImageCell.self)
        tableView.registerNib(for: PostActionCell.self)
        
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    // MARK: - 
    
    func loadData() {
        self.paginationHelper.reloadData(completion: { [unowned self] (posts) in
            self.posts = posts
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            self.tableView.reloadData()
        })
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
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
            cell.usernameLabel.text = post.poster.username
            cell.delegate = self
            
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
    
    func configureCell(_ cell: PostActionCell, with post: Post) {
        cell.timeAgoLabel.text = timestampFormatter.string(from: post.creationDate)
        cell.likeButton.isSelected = post.isLiked
        cell.likesCountLabel.text = "\(post.likesCount) likes"
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
            
        default:
            fatalError()
        }
    }
}

extension HomeViewController: PostHeaderCellDelegate {
    func didTapOptionsButton(_ optionsButton: UIButton, on cell: PostHeaderCell) {
        guard let indexPath = tableView.indexPath(for: cell)
              else { return }
        
        let poster = posts[indexPath.section].poster
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
        
        LikeService.setIsLiked(!post.isLiked, for: post) { (success) in
            defer {
                likeButton.isUserInteractionEnabled = true
            }
            
            guard success else { return }
            
            post.likesCount += !post.isLiked ? 1 : -1
            post.isLiked = !post.isLiked
            
            guard let cell = self.tableView.cellForRow(at: indexPath) as? PostActionCell
                else { return }
            
            DispatchQueue.main.async {
                self.configureCell(cell, with: post)
            }
        }
        
    }
}
