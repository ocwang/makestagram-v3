//
//  UIImage+AspectHeight.swift
//  Makestagram
//
//  Created by Chase Wang on 4/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

extension UIImage {
    var aspectHeight: CGFloat {
        let heightRatio = size.height / 736
        let widthRatio = size.width / 414
        let aspectRatio = fmax(heightRatio, widthRatio)
        
        return size.height / aspectRatio
    }
}
