//
//  Constants.swift
//  Makestagram
//
//  Created by Chase Wang on 3/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import CoreGraphics

struct Constants {
    struct Segue {
        static let createUsername = "toCreateUsername"
    }
    
    struct UserDefaults {
        static let currentUser = "currentUser"
        static let uid = "uid"
        static let username = "username"
    }
    
    struct TabBarItem {
        static let centerTag = 1
    }
    
    struct Profile {
        static let numberOfColumns = 3
        static let itemSpacing: CGFloat = 1.5
    }
}
