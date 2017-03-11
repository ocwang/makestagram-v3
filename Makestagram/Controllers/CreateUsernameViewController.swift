//
//  CreateUsernameViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 3/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateUsernameViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.layer.cornerRadius = 6
    }
    
    // MARK: - IBActions
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
         // check if user exists, otherwise set username
        
        if let uid = FIRAuth.auth()?.currentUser?.uid, let username = usernameTextField.text, !username.isEmpty {
            let ref = FIRDatabase.database().reference()
            ref.child("users").child(uid).setValue(["username": username])
            
            let storyboard = UIStoryboard(type: .main)
            view.window?.setRootViewControllerToInitialViewController(of: storyboard)
        }
    }
}
