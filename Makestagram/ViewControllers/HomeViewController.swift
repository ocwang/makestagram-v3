//
//  HomeViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 3/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {

    // TODO: Move to settings
    var handle: FIRAuthStateDidChangeListenerHandle?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: Move to settings
        handle = FIRAuth.auth()?.addStateDidChangeListener() { [unowned self] (auth, user) in
            guard user == nil, let window = self.view.window else { return }

            let storyboard = StoryboardType.login.storyboard
            if let initialViewController = storyboard.instantiateInitialViewController() {
                window.rootViewController = initialViewController
                window.makeKeyAndVisible()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // TODO: Move to settings
        if let handle = handle {
            FIRAuth.auth()?.removeStateDidChangeListener(handle)
        }
    }

    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        // TODO: Move to settings
        do {
            try FIRAuth.auth()?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
