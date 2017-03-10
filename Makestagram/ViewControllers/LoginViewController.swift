//
//  LoginViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 3/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuthUI

class LoginViewController: UIViewController {

    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 6
    }
    
    // MARK: - IBActions
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if let authUI = FUIAuth.defaultAuthUI() {
            authUI.delegate = self
            
            let authViewController = authUI.authViewController()
            present(authViewController, animated: true)
        }
    }
}

extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        if let error = error {
            print("Error signing in: \(error.localizedDescription)")
        }
        
        guard user != nil else { return }
        
        
        // TODO: check if user exists, if they don't choose username, otherwise log them in
        
        performSegue(withIdentifier: Constants.Segue.createUsername, sender: self)
        
//        let storyboard = UIStoryboard(name: Constants.Storyboard.main, bundle: Bundle.main)
//        
//        guard let window = view.window,
//            let initialViewController = storyboard.instantiateInitialViewController()
//            else { return }
//        
//        window.rootViewController = initialViewController
//        window.makeKeyAndVisible()
    }
}
