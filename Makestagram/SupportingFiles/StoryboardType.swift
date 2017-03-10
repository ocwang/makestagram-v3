//
//  MGStoryboard.swift
//  Makestagram
//
//  Created by Chase Wang on 3/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

enum StoryboardType: String {
    case main
    case login
    
    var storyboard: UIStoryboard {
        return UIStoryboard(name: self.rawValue.capitalized, bundle: Bundle.main)
    }
}
