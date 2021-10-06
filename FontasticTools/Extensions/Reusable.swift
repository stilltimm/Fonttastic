//
//  Reusable.swift
//  FontasticTools
//
//  Created by Timofey Surkov on 06.10.2021.
//

import Foundation

public protocol Reusable: AnyObject {

    // MARK: - Type Properties

    static var reuseIdentifier: String { get }
}

// MARK: - Default Implementation

extension Reusable {

    // MARK: - Type Properties

    public static var reuseIdentifier: String { String(describing: self) }
}
