//
//  UIWindow+Utility.swift
//  Makestagram
//
//  Created by Chase Wang on 3/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

extension UIWindow {
    func setRootViewControllerToInitialViewController(of storyboard: UIStoryboard) {
        guard let initialViewController = storyboard.instantiateInitialViewController() else {
            fatalError("Error: couldn't instantiate initial view controller for storyboard.")
        }
        
        rootViewController = initialViewController
        makeKeyAndVisible()
    }
}
