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
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid,
            let username = usernameTextField.text,
            !username.isEmpty else { return }
        
        UserService.createUser(username, forUID: uid, completion: { [unowned self] (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            let user = User(uid: uid, username: username)
            User.setCurrentUser(user, archiveData: true)
            
            let storyboard = UIStoryboard(type: .main)
            self.view.window?.setRootViewControllerToInitialViewController(of: storyboard)
        })
    }
}
