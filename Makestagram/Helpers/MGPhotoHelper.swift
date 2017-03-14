//
//  PhotoHelper.swift
//  Makestagram
//
//  Created by Chase Wang on 3/11/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

protocol MGPhotoHelperDelegate: class {
    func didTapTakePhotoButton(for photoHelper: MGPhotoHelper)
    func didTapUploadFromLibraryButton(for photoHelper: MGPhotoHelper)
    
}

class MGPhotoHelper: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: MGPhotoHelperDelegate?
    
    let dateFormatter = ISO8601DateFormatter()
    
    let storageRef: FIRStorageReference 
    
    let currentUser: FIRUser
    
    init(currentUser: FIRUser, storageRef: FIRStorageReference) {
        self.currentUser = currentUser
        self.storageRef = storageRef
        
        super.init()
    }
    
    func presentActionSheet(from viewController: UIViewController) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let capturePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { [unowned self] action in
                self.delegate?.didTapTakePhotoButton(for: self)
            })
            
            alertController.addAction(capturePhotoAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let uploadAction = UIAlertAction(title: "Upload from Library", style: .default, handler: { [unowned self] action in
                self.delegate?.didTapUploadFromLibraryButton(for: self)
            })
            
            alertController.addAction(uploadAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        viewController.present(alertController, animated: true)
    }
    
    func presentImagePickerController(with sourceType: UIImagePickerControllerSourceType, from viewController: UIViewController) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        
        viewController.present(imagePickerController, animated: true)
    }

    func createPost(for image: UIImage) {
        // scale image quality down
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else { return }
        
        let imageRef = generateImageRef()
        let height = aspectHeight(for: image)

        StorageService.uploadImageData(imageData, atImageRef: imageRef) { [unowned self] (success, downloadURL) in
            guard success, let downloadURL = downloadURL else { return }
            
            let newPost = Post(imageURL: downloadURL, imageHeight: height)
            PostService.createPost(newPost, forUID: self.currentUser.uid)
        }
    }
}

// MARK: - Helper Methods

extension MGPhotoHelper {
    func generateImageRef() -> FIRStorageReference {
        let uid = currentUser.uid
        let timestamp = dateFormatter.string(from: Date())
        let pathIdentifier = generateRandomString(length: 6)
        
        return storageRef.child("images/posts/\(uid)/\(timestamp)-\(pathIdentifier).jpg")
    }
    
    fileprivate func aspectHeight(for image: UIImage) -> CGFloat {
        let heightRatio = image.size.height / UIScreen.main.bounds.height
        let widthRatio = image.size.width / UIScreen.main.bounds.width
        let aspectRatio = fmax(heightRatio, widthRatio)
        
        return image.size.height / aspectRatio
    }
    
    fileprivate func generateRandomString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        
        return (0..<length).reduce("") { (accumulator, _) -> String in
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            
            return accumulator + String(newCharacter)
        }
    }
}

extension MGPhotoHelper: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            createPost(for: selectedImage)
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
