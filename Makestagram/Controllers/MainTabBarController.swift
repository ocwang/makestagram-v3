//
//  MainTabBarController.swift
//  Makestagram
//
//  Created by Chase Wang on 3/11/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    // MARK: - Properties
    
    let photoHelper = MGPhotoHelper()
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoHelper.delegate = self
        delegate = self
        
        tabBar.unselectedItemTintColor = .black
    }
}

// MARK: - UITabBarControllerDelegate

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag == 1 {
            photoHelper.presentActionSheet(from: self)
            return false
        }
        
        return true
    }
}

extension MainTabBarController: MGPhotoHelperDelegate {
    func didTapTakePhotoButton(for photoHelper: MGPhotoHelper) {
        photoHelper.presentImagePickerController(with: .camera, from: self)
    }
    
    func didTapUploadFromLibraryButton(for photoHelper: MGPhotoHelper) {
        photoHelper.presentImagePickerController(with: .photoLibrary, from: self)
    }
}
