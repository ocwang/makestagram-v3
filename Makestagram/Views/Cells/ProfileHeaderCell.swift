//
//  ProfileHeaderCell.swift
//  Makestagram
//
//  Created by Chase Wang on 3/17/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

protocol ProfileHeaderCellDelegate: class {
    func didTapFollowButton(_ followButton: UIButton, on cell: ProfileHeaderCell)
}

class ProfileHeaderCell: UITableViewCell {
    
    static let height: CGFloat = 115
    
    // MARK: - Properties
    
    weak var delegate: ProfileHeaderCellDelegate?
    
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
        followButton.layer.masksToBounds = true
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.bounds.width / 2
    }
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        delegate?.didTapFollowButton(sender, on: self)
    }
    
    func setFollowButton(withTitle title: String, isBlue: Bool) {
        let buttonColor: UIColor = isBlue ? .mg_blue : .white
        let titleColor: UIColor = isBlue ? .white : .mg_blue
        
        followButton.setTitle(title, for: .normal)
        followButton.setTitleColor(titleColor, for: .normal)
        followButton.setBackgroundColor(color: buttonColor, forState: .normal)
    }
}
