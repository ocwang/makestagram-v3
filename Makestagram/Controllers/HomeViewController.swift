//
//  HomeViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 3/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "PostImageCell", bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: "PostImageCell")
        
        let nib2 = UINib(nibName: "PostHeaderCell", bundle: .main)
        tableView.register(nib2, forCellReuseIdentifier: "PostHeaderCell")
        
        let nib3 = UINib(nibName: "PostActionCell", bundle: .main)
        tableView.register(nib3, forCellReuseIdentifier: "PostActionCell")
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
            let cell: PostImageCell = tableView.dequeueReusableCell()
            cell.backgroundColor = .red
            
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
