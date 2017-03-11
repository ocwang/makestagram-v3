//
//  MGStoryboard.swift
//  Makestagram
//
//  Created by Chase Wang on 3/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

extension UIStoryboard {

    // https://medium.com/swift-programming/uistoryboard-safer-with-enums-protocol-extensions-and-generics-7aad3883b44d#.lzt6l65vr
    
    enum MGType: String {
        case main
        case login
        
        var filename: String {
            return rawValue.capitalized
        }
    }
    
    convenience init(type: MGType, bundle: Bundle? = nil) {
        self.init(name: type.filename, bundle: bundle)
    }
}
