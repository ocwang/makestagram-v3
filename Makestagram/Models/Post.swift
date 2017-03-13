//
//  Post.swift
//  Makestagram
//
//  Created by Chase Wang on 3/12/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class Post {
    let key: String
    let imageURL: String
    
    init?(snapshot: FIRDataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let imageURL = dict["image_url"] as? String else { return nil }
        
        self.key = snapshot.key
        self.imageURL = imageURL
    }
}
