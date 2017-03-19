//
//  ProfileHeaderCell.swift
//  Makestagram
//
//  Created by Chase Wang on 3/17/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class ProfileHeaderCell: UITableViewCell {
    
    static let height: CGFloat = 115
    
    // MARK: - Subviews
    
    @IBOutlet weak var userPhotoImageView: UIImageView!
    
    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        followButton.layer.cornerRadius = 4
        followButton.layer.borderWidth = 1
        followButton.backgroundColor = .white
        followButton.layer.borderColor = UIColor.mg_lightGray.cgColor
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.bounds.width / 2
    }
}
