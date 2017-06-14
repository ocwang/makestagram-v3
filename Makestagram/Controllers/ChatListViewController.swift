//
//  ChatListViewController.swift
//  Makestagram
//
//  Created by Chase Wang on 6/6/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController {

    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - IBActions
    
    @IBAction func dismissButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true)
    }
}
