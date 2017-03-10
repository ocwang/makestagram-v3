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
        setRootViewController()
        
        return true
    }
    
    func setRootViewController() {
        guard let window = window else { return }
        
        let type: StoryboardType = FIRAuth.auth()?.currentUser == nil ? .login : .main
        let storyboard = type.storyboard
        
        if let initialViewController = storyboard.instantiateInitialViewController() {
            window.rootViewController = initialViewController
            window.makeKeyAndVisible()
        }
    }
}

extension AppDelegate {
    fileprivate func configureThirdPartyLibraries() {
        FIRApp.configure()
    }
}
