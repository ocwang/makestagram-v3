//
//  User.swift
//  Makestagram
//
//  Created by Chase Wang on 3/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User {
    let uid: String
    let username: String
    
    init?(snapshot: FIRDataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String
            else { return nil }
        
        self.uid = snapshot.key
        self.username = username
    }
}
