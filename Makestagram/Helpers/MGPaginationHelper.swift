//
//  MGPaginationHelper.swift
//  Makestagram
//
//  Created by Chase Wang on 3/22/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation

class MGPaginationHelper {
    
    // TODO: consider making delegate instead of closure to pass data base
    
    enum MGPaginationState {
        case initial
        case ready
        case loading
        case end
    }
    
    // MARK: - Properties
    
    let pageSize = 2
    var state: MGPaginationState = .initial
    var lastPostKey: String?
    
    // MARK: -
    
    func paginate(completion: @escaping ([Post]) -> Void) {
        switch state {
        case .initial:
            lastPostKey = nil
            fallthrough
            
        case .ready:
            state = .loading
            // TODO: Make this generic / passed in
            UserService.timeline(pageSize: UInt(pageSize), lastPostKey: lastPostKey) { [unowned self] (posts) in
                defer {
                    if let lastPostKey = posts.last?.key {
                        self.lastPostKey = lastPostKey
                    }
                    
                    self.state = posts.count < self.pageSize ? .end : .ready
                }
                
                guard let _ = self.lastPostKey else {
                    return completion(posts)
                }
                
                var newPosts = Array(posts)
                newPosts.remove(at: 0)
                completion(newPosts)
            }
            
        case .loading, .end:
            return
        }
    }
    
    func reloadData(completion: @escaping ([Post]) -> Void) {
        state = .initial
        
        paginate(completion: completion)
    }
}
