//
//  ProfileHeaderView.swift
//  Makestagram
//
//  Created by Chase Wang on 5/14/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

protocol ProfileHeaderViewDelegate: class {
    func didTapSettingsButton(_ button: UIButton, on headerView: ProfileHeaderView)
}

class ProfileHeaderView: UICollectionReusableView {
    
    static let height: CGFloat = 180
    
    // MARK: - Properties
    
    weak var delegate: ProfileHeaderViewDelegate?
    
    // MARK: - Subviews
    
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        settingsButton.layer.cornerRadius = 6
        settingsButton.layer.borderColor = UIColor.mg_lightGray.cgColor
        settingsButton.layer.borderWidth = 1
    }
    
    // MARK: - IBAction
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        delegate?.didTapSettingsButton(sender, on: self)
    }
}
