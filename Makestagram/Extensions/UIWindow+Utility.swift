//
//  UIWindow+Utility.swift
//  Makestagram
//
//  Created by Chase Wang on 3/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

extension UIWindow {
    func makeKeyAndVisible(for viewController: UIViewController) {
        rootViewController = viewController
        makeKeyAndVisible()
    }
}
