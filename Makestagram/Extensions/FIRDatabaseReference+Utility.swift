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
    func incrementInTransactionBlock(completion: ((Error?) -> Void)?) {
        perform({ $0 + 1 }, inTransactionBlockWithCompletion: completion)
    }
    
    func decrementInTransactionBlock(completion: ((Error?) -> Void)?) {
        perform({ $0 - 1 }, inTransactionBlockWithCompletion: completion)
    }
    
    func perform(_ transform: @escaping (Int) -> Int, inTransactionBlockWithCompletion completion: ((Error?) -> Void)?) {
        runTransactionBlock({ (mutableData) -> FIRTransactionResult in
            let currentCount = mutableData.value as? Int ?? 0
            mutableData.value = transform(currentCount)
            
            return FIRTransactionResult.success(withValue: mutableData)
        }, andCompletionBlock: { (error, committed, snapshot) in
            completion?(error)
        })
    }
}
