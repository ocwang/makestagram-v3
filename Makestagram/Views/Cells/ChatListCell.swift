//
//  ChatListCell.swift
//  Makestagram
//
//  Created by Chase Wang on 6/19/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class ChatListCell: UITableViewCell {
    
    static let height: CGFloat = 71
    
    // MARK: - Subviews

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
