//
//  UITableView+Utility.swift
//  Makestagram
//
//  Created by Chase Wang on 3/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

extension UITableView {
    func registerNib(for cellClass: AnyClass) {
        let className = String(describing: cellClass)
        let nib = UINib(nibName: className, bundle: .main)
        
        register(nib, forCellReuseIdentifier: className)
    }
    
    func dequeueReusableCell<T: UITableViewCell>() -> T where T: ClassIdentifiable {
        guard let cell = dequeueReusableCell(withIdentifier: T.mgIdentifier) as? T else {
            fatalError("Error dequeuing cell for identifier \(T.mgIdentifier)")
        }
        
        return cell
    }
}
