//
//  PostActionCell.swift
//  Makestagram
//
//  Created by Chase Wang on 3/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class PostActionCell: UITableViewCell {

    // MARK: - Class Vars
    
    static let height: CGFloat = 46
    
    // MARK: - Subviews
    
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - IBActions
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        print("like button tapped")
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        print("comment button tapped")
    }
    
    @IBAction func directMessageButtonTapped(_ sender: UIButton) {
        print("direct message button tapped")
    }
}
