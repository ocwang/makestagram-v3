//
//  PostActionCell.swift
//  Makestagram
//
//  Created by Chase Wang on 3/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

protocol PostActionCellDelegate: class {
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell)
}

class PostActionCell: UITableViewCell {

    // MARK: - Class Vars
    
    static let height: CGFloat = 46

    // MARK: - Properties
    
    weak var delegate: PostActionCellDelegate?
    
    // MARK: - Subviews
    
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var bottomBorder: UIView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - IBActions
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        delegate?.didTapLikeButton(sender, on: self)
    }
}
