//
//  UICollectionView+Utility.swift
//  Makestagram
//
//  Created by Chase Wang on 5/14/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

extension UICollectionView {
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, for indexPath: IndexPath) -> T where T: ClassIdentifiable {
        guard let supplementaryView = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.mgIdentifier, for: indexPath) as? T else {
            fatalError("Error dequeuing reusable supplementary view for identifier \(T.mgIdentifier)")
        }
        
        return supplementaryView
    }
    
    func dequeueReusableCell<T: UICollectionReusableView>(for indexPath: IndexPath) -> T where T: ClassIdentifiable {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.mgIdentifier, for: indexPath) as? T else {
            fatalError("Error dequeuing cell for identifier \(T.mgIdentifier)")
        }
        
        return cell
    }
}
