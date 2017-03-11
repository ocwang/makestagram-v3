//
//  PostHeaderCell.swift
//  Makestagram
//
//  Created by Chase Wang on 3/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class PostHeaderCell: UITableViewCell {
    
    static let height: CGFloat = 53

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
     
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
    }

    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        print("options button tapped")
    }
}
