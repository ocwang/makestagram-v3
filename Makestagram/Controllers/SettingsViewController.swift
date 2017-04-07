//
//  SettingsViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 3/13/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    var handle: FIRAuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var logOutButton: UIButton!
    
    // MARK; - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logOutButton.layer.cornerRadius = 6
        logOutButton.backgroundColor = UIColor.mg_blue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = FIRAuth.auth()?.addStateDidChangeListener() { [unowned self] (auth, user) in
            guard user == nil else { return }
            
            let initialViewController = UIStoryboard.initialViewController(for: .login)
            self.view.window?.setRootViewController(with: initialViewController)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let handle = handle {
            FIRAuth.auth()?.removeStateDidChangeListener(handle)
        }
    }

    // MARK: - IBActions
    
    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error as NSError {
            print ("Error signing out: %@", error)
        }
    }
}
