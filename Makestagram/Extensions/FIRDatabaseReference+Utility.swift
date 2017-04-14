//
//  FIRDatabaseReference+Utility.swift
//  Makestagram
//
//  Created by Chase Wang on 3/20/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension FIRDatabaseReference {
    func incrementInTransactionBlock(success: @escaping (Bool) -> Void) {
        perform({ $0 + 1 }, inTransactionBlockWithSuccess: success)
    }
    
    func decrementInTransactionBlock(success: @escaping (Bool) -> Void) {
        perform({ $0 - 1 }, inTransactionBlockWithSuccess: success)
    }
    
    func perform(_ transform: @escaping (Int) -> Int, inTransactionBlockWithSuccess success: @escaping (Bool) -> Void) {
        runTransactionBlock({ (mutableData) -> FIRTransactionResult in
            let currentCount = mutableData.value as? Int ?? 0
            mutableData.value = transform(currentCount)
            
            return FIRTransactionResult.success(withValue: mutableData)
        }, andCompletionBlock: { (error, committed, snapshot) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
            } else {
                success(true)
            }
        })
    }
}
