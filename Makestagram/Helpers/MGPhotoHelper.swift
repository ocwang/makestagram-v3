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
    
    func uploadImageToFirebase(imageData: Data) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let storageRef = FIRStorage.storage().reference()
        
        let timestamp = dateFormatter.string(from: Date())
        let pathIdentifier = randomString(length: 6)
        let imageRef = storageRef.child("images/posts/\(uid)/\(timestamp)-\(pathIdentifier).png")
        
        _ = imageRef.put(imageData, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else { return }
            // create posts
            
            // create user posts
            
            
            
            
            
            
//            let ref = Firebase(url: "https://<YOUR-FIREBASE-APP>.firebaseio.com")
//            // Generate a new push ID for the new post
//            let newPostRef = ref.childByAppendingPath("posts").childByAutoId()
//            let newPostKey = newPostRef.key
//            // Create the data we want to update
//            let updatedUserData = ["users/posts/\(newPostKey)": true, "posts/\(newPostKey)": ["title": "New Post", "content": "Here is my new post!"]]
//            // Do a deep-path update
//            ref.updateChildValues(updatedUserData, withCompletionBlock: { (error, ref) -> Void in
//                if (error) {
//                    print("Error updating data: \(error.description)")
//                }
//            })
            
            
//            let updatedUser = ["name": "Shannon", "username": "shannonrules"]
//            let ref = Firebase(url: "https://<YOUR-FIREBASE-APP>.firebaseio.com")
//            
//            let fanoutObject = ["/users/1": updatedUser, "/usersWhoAreCool/1": updatedUser, "/usersToGiveFreeStuffTo/1", updatedUser]
//            
//            ref.updateChildValues(updatedUser)
            
            
            if let downloadURL = metadata.downloadURL() {
                
                let databaseRef = FIRDatabase.database().reference()
                let newPostRef = databaseRef.child("posts").childByAutoId()
                let newPostKey = newPostRef.key
                
                
                let updatedUserData: [String : Any] = ["users/\(uid)/posts/\(newPostKey)" : true,
                                                       "posts/\(newPostKey)" : ["image_url" : downloadURL.absoluteString]]
                databaseRef.updateChildValues(updatedUserData)
                
                
//                FIRDatabase.database().reference().child("posts").childByAutoId().setValue(["image_url" : downloadURL.absoluteString])
            }
        }
        
    }

    func randomString(length: Int) -> String {
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
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let imageData = UIImagePNGRepresentation(selectedImage) {
            
            uploadImageToFirebase(imageData: imageData)
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
