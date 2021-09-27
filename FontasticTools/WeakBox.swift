//
//  WeakBox.swift
//  Fontastic
//
//  Created by Timofey Surkov on 26.09.2021.
//

import Foundation

struct WeakBox<T: AnyObject> {

    // MARK: - Public Instance Properties

    var value: T? {
        get { wrapped }
        set { wrapped = newValue }
    }

    // MARK: - Private Instance Properties

    private weak var wrapped: T?

    // MARK: - Initializers

    init(_ value: T) {
        self.wrapped = value
    }
}
