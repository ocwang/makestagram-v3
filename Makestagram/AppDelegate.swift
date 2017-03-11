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
    
    func setInitialRootViewController() {
        let type: UIStoryboard.MGType = FIRAuth.auth()?.currentUser == nil ? .login : .main
        let storyboard = UIStoryboard(type: type)
        
        window?.setRootViewControllerToInitialViewController(of: storyboard)
    }
}

extension AppDelegate {
    fileprivate func configureThirdPartyLibraries() {
        FIRApp.configure()
    }
}
