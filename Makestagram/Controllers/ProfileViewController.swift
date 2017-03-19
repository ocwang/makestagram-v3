//
//  ProfileViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 3/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var user: User!
    
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
        tableView.rowHeight = 115
        navigationItem.title = user.username
        
        
    }
    
    
    func findFriendsBarButtonItemTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Constants.Segue.findFriends, sender: self)
    }

}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileHeaderCell = tableView.dequeueReusableCell()
        cell.postsCountLabel.text = String(user.postsCount)
        cell.followersCountLabel.text = String(user.followersCount)
        cell.followingCountLabel.text = String(user.followingCount)
        
        return cell
    }
}
