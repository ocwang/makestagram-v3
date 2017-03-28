//
//  FindFriendCell.swift
//  Makestagram
//
//  Created by Chase Wang on 3/16/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

protocol FindFriendCellDelegate: class {
    func didTapFollowButton(_ followButton: UIButton, on cell: FindFriendCell)
}

class FindFriendCell: UITableViewCell {

    // MARK: - Instance Vars
    
    weak var delegate: FindFriendCellDelegate?
    
    // MARK: - Subviews
    
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        followButton.layer.borderColor = UIColor.mg_lightGray.cgColor
        followButton.layer.borderWidth = 1
        followButton.layer.cornerRadius = 6
        followButton.clipsToBounds = true
        
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitleColor(.white, for: .normal)
        followButton.setBackgroundColor(color: .mg_blue, forState: .normal)
        
        followButton.setTitle("Following", for: .selected)
        followButton.setTitleColor(.mg_offBlack, for: .selected)
        followButton.setBackgroundColor(color: .white, forState: .selected)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.bounds.width / 2
    }

    // MARK: - IBActions
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        delegate?.didTapFollowButton(sender, on: self)
    }
}
