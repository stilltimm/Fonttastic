//
//  Array+Utils.swift
//  Fontastic
//
//  Created by Timofey Surkov on 24.09.2021.
//

import Foundation

extension Array {

    subscript(safe index: Index) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}
