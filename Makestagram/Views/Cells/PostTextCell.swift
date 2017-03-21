//
//  PostTextCell.swift
//  Makestagram
//
//  Created by Chase Wang on 3/20/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class PostTextCell: UITableViewCell {
    
    static let height: CGFloat = 24
    
    // MARK: - Subviews
    
    @IBOutlet weak var postTextLabel: UILabel!

    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
