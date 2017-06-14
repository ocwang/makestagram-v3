//
//  ProfileViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 5/14/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Kingfisher

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    var user: User!
    var posts = [Post]()
    
    var authHandle: FIRAuthStateDidChangeListenerHandle?
    var profileHandle: FIRDatabaseHandle = 0
    var profileRef: FIRDatabaseReference?
    
    // MARK: - Subviews

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = user ?? User.current
        navigationItem.title = user.username
        
        authHandle = FIRAuth.auth()?.addStateDidChangeListener() { [unowned self] (auth, user) in
            guard user == nil else { return }
            
            let initialViewController = UIStoryboard.initialViewController(for: .login)
            self.view.window?.makeKeyAndVisible(for: initialViewController)
        }
        
        profileHandle = UserService.observeProfile(for: user) { [unowned self] (ref, user, posts) in
            self.profileRef = ref
            self.user = user
            self.posts = posts
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    deinit {
        if let authHandle = authHandle {
            FIRAuth.auth()?.removeStateDidChangeListener(authHandle)
        }
        
        profileRef?.removeObserver(withHandle: profileHandle)
    }
}

// MARK: - UICollectionViewDataSource

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PostThumbImageCell = collectionView.dequeueReusableCell(for: indexPath)
        
        let post = posts[indexPath.row]
        let imageURL = URL(string: post.imageURL)
        cell.thumbImageView.kf.setImage(with: imageURL)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader else {
            fatalError("Unexpected element kind.")
        }
        
        let headerView: ProfileHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
        headerView.delegate = self
        
        let postCount = user.postCount ?? 0
        headerView.postCountLabel.text = "\(postCount)"
        
        let followerCount = user.followerCount ?? 0
        headerView.followerCountLabel.text = "\(followerCount)"
        
        let followingCount = user.followingCount ?? 0
        headerView.followingCountLabel.text = "\(followingCount)"
        
        return headerView
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns = CGFloat(Constants.Profile.numberOfColumns)
        let spacing = Constants.Profile.itemSpacing
        let totalHorizontalSpacing = (columns - 1) * spacing
        
        let itemWidth = (collectionView.bounds.width - totalHorizontalSpacing) / columns
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.Profile.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.Profile.itemSpacing
    }
}

// MARK: - ProfileHeaderViewDelegate

extension ProfileViewController: ProfileHeaderViewDelegate {
    func didTapSettingsButton(_ button: UIButton, on headerView: ProfileHeaderView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let signOutAction = UIAlertAction(title: "Sign Out", style: .default) { _ in
            do {
                try FIRAuth.auth()?.signOut()
            } catch let error as NSError {
                assertionFailure("Error signing out: \(error.localizedDescription)")
            }
        }
        alertController.addAction(signOutAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}
