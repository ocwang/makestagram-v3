//
//  UIWindow+Utility.swift
//  Makestagram
//
//  Created by Chase Wang on 3/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

extension UIWindow {
    
    // TODO: don't like this naming because it says nothing about makeKeyAndVisible()
    // should this be removed altogether
    
    func setRootViewController(with viewController: UIViewController) {
        rootViewController = viewController
        makeKeyAndVisible()
    }
}
