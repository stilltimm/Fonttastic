//
//  UICollectionView+Reusable.swift
//  FontasticTools
//
//  Created by Timofey Surkov on 06.10.2021.
//

import UIKit

extension UICollectionView {

    // MARK: - Instance Methods

    public func registerReusableCell<T>(of type: T.Type) where T: UICollectionViewCell & Reusable {
        register(type, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    public func dequeueReusableCell<T>(for indexPath: IndexPath) -> T where T: UICollectionViewCell & Reusable {
        return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }

    public func registerAndDequeueReusableCell<T>(
        for indexPath: IndexPath
    ) -> T where T: UICollectionViewCell & Reusable {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)

        return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }

    public func registerReusableView<T>(
        of type: T.Type,
        forViewOfKind kind: String
    ) where T: UICollectionReusableView & Reusable {
        register(type, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
    }

    public func dequeueReusableView<T>(
        ofKind kind: String,
        for indexPath: IndexPath
    ) -> T where T: UICollectionReusableView & Reusable {
        return dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: T.reuseIdentifier,
            for: indexPath
        ) as! T
    }
}
