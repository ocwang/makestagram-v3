//
//  StorageService.swift
//  Makestagram
//
//  Created by Chase Wang on 3/13/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseStorage

class StorageService {
    static func uploadImageData(_ imageData: Data, atImageRef ref: FIRStorageReference, completion: @escaping (Bool, String?) -> Void) {
        _ = ref.put(imageData, metadata: nil, completion: { (metadata, error) in
            guard error == nil,
                let metadata = metadata,
                let downloadURL = metadata.downloadURL()
                else { return completion(false, nil) }
            
            completion(true, downloadURL.absoluteString)
        })
    }
}
