//
//  Array+Utils.swift
//  FontasticTools
//
//  Created by Timofey Surkov on 06.10.2021.
//

import Foundation

extension Array {

    public subscript (safeRange range: Range<Index>) -> Array<Element> {
        let safeLowerBound = Swift.max(range.lowerBound, self.startIndex)
        let safeUpperBound = Swift.min(range.upperBound, self.endIndex)
        return Array(self[safeLowerBound..<safeUpperBound])
    }
}
