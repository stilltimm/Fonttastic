//
//  Array+Utils.swift
//  FontasticTools
//
//  Created by Timofey Surkov on 06.10.2021.
//

import Foundation

extension Array {

    public subscript (safe index: Index) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }

    public subscript (safeRange range: Range<Index>) -> [Element] {
        let safeLowerBound = Swift.max(range.lowerBound, self.startIndex)
        let safeUpperBound = Swift.min(range.upperBound, self.endIndex)
        return Array(self[safeLowerBound..<safeUpperBound])
    }
}
