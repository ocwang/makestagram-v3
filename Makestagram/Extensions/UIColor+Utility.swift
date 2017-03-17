//
//  UIColor+Utility.swift
//  Makestagram
//
//  Created by Chase Wang on 3/16/17.
//  Copyright © 2017 Make School. All rights reserved.
//
import UIKit

extension UIColor {
    /*
     * Converts hex integer into UIColor
     *
     * Usage: UIColor(hex: 0xFFFFFF)
     *
     */
    
    private convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
    // MARK: Brand Colors
    
    static var mg_blue: UIColor {
        return UIColor(hex: 0x3796F0)
    }
    
    static var mg_lightGray: UIColor {
        return UIColor(hex: 0xDDDCDC)
    }
    
    static var mg_offBlack: UIColor {
        return UIColor(hex: 0x262626)
    }
}
