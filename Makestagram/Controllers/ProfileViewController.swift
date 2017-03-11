//
//  ProfileViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 3/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    // TODO: Move to settings
    var handle: FIRAuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: Move to settings
        handle = FIRAuth.auth()?.addStateDidChangeListener() { [unowned self] (auth, user) in
            guard user == nil else { return }
            
            let storyboard = UIStoryboard(type: .login)
            self.view.window?.setRootViewControllerToInitialViewController(of: storyboard)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // TODO: Move to settings
        if let handle = handle {
            FIRAuth.auth()?.removeStateDidChangeListener(handle)
        }
    }
    
    @IBAction func logOutButtonTapped(_ sender: UIBarButtonItem) {
        // TODO: Move to settings
        do {
            try FIRAuth.auth()?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }

    }
}
