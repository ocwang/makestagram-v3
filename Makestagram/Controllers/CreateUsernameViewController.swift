//
//  CreateUsernameViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 3/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth

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
        guard let firUser = FIRAuth.auth()?.currentUser,
            let username = usernameTextField.text,
            !username.isEmpty else { return }
        
        UserService.create(firUser, username: username) { [unowned self] (user) in
            guard let user = user else {
                // handle error
                return
            }
            
            User.setCurrentUser(user, archiveData: true)
            
            let initialViewController = UIStoryboard.initialViewController(for: .main)
            self.view.window?.setRootViewController(with: initialViewController)
        }
    }
}
