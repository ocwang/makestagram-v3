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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ref = FIRDatabase.database().reference()
        
        
        _ = ref.child("posts").observe(FIRDataEventType.value, with: { [unowned self] (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                self.posts = snapshots.flatMap(Post.init)
                self.tableView.reloadData()
            }
        })
        
        tableView.registerNib(for: PostHeaderCell.self)
        tableView.registerNib(for: PostImageCell.self)
        tableView.registerNib(for: PostActionCell.self)
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
        
        
        
        switch indexPath.row {
        case 0:
            let cell: PostHeaderCell = tableView.dequeueReusableCell()
            cell.usernameLabel.text = "ocwang"
            
            return cell
            
        case 1:
            let post = posts[indexPath.section]
            let cell: PostImageCell = tableView.dequeueReusableCell()
            
            let imageURL = URL(string: post.imageURL)
            cell.postImageView.kf.setImage(with: imageURL)
            
            
            return cell
            
        case 2:
            let cell: PostActionCell = tableView.dequeueReusableCell()
            return cell
            
        default:
            fatalError()
        }
        
        
        let cell: PostImageCell = tableView.dequeueReusableCell()
        cell.backgroundColor = .red
        
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0: return PostHeaderCell.height
        case 1: return view.bounds.width
        case 2: return PostActionCell.height
        default: fatalError()
        }
        
        
    }
}
