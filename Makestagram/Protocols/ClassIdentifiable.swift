//
//  ClassIdentifiable.swift
//  Makestagram
//
//  Created by Chase Wang on 5/14/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

protocol ClassIdentifiable {
    static var mgIdentifier: String { get }
}

extension ClassIdentifiable {
    static var mgIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView: ClassIdentifiable {}

extension UITableViewCell: ClassIdentifiable {}
