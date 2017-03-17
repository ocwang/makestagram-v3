//
//  AppDelegate.swift
//  Makestagram
//
//  Created by Chase Wang on 3/8/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configureThirdPartyLibraries()
        setInitialRootViewController()
        
        return true
    }
}

extension AppDelegate {
    fileprivate func configureThirdPartyLibraries() {
        FIRApp.configure()
    }
    
    fileprivate func setInitialRootViewController() {
        let defaults = UserDefaults.standard
        let storyboard: UIStoryboard
        
        guard FIRAuth.auth()?.currentUser != nil,
            let userData = defaults.object(forKey: Constants.UserDefaults.currentUser) as? Data,
            let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User else {
                storyboard = UIStoryboard(type: .login)
                window?.setRootViewControllerToInitialViewController(of: storyboard)
                return
        }
        
        User.current = user
        
        storyboard = UIStoryboard(type: .main)
        window?.setRootViewControllerToInitialViewController(of: storyboard)
    }
}
