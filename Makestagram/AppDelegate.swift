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
    
    // MARK: - App Lifecycle

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
        let initialViewController: UIViewController
        
        guard FIRAuth.auth()?.currentUser != nil,
            let userData = defaults.object(forKey: Constants.UserDefaults.currentUser) as? Data,
            let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User else {
                initialViewController = UIStoryboard.initialViewController(for: .login)
                window?.setRootViewController(with: initialViewController)
                return
        }
        
        User.setCurrent(user)
        
        initialViewController = UIStoryboard.initialViewController(for: .main)
        window?.setRootViewController(with: initialViewController)
    }
}
