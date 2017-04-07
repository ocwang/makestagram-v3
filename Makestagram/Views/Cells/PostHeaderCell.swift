//
//  PostHeaderCell.swift
//  Makestagram
//
//  Created by Chase Wang on 3/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

protocol PostHeaderCellDelegate: class {
    func didTapOptionsButton(_ optionsButton: UIButton, on cell: PostHeaderCell)
}

class PostHeaderCell: UITableViewCell {
    
    static let height: CGFloat = 53
    
    // MARK: - Properties
    
    weak var delegate: PostHeaderCellDelegate?
    
    // MARK: - Subviews

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    
    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
     
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
    }
    
    // MARK: - IBActions

    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        delegate?.didTapOptionsButton(sender, on: self)
    }
}
