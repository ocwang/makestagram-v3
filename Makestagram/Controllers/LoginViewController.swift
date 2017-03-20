//
//  LoginViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 3/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
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
        
        guard let user = user else { return }
        
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { [unowned self] snapshot in
            if let user = User(snapshot: snapshot) {
                User.setCurrentUser(user, archiveData: true)
                
                let storyboard = UIStoryboard(type: .main)
                self.view.window?.setRootViewControllerToInitialViewController(of: storyboard)
            } else {
                self.performSegue(withIdentifier: Constants.Segue.createUsername, sender: self)
            }
        })
    }
}
