//
//  FontModel.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import Foundation

public struct FontModel: Codable, Hashable {

    public let name: String
    public let displayName: String
    public let resourceType: FontResourceType
    public let status: FontStatus

    public init(
        name: String,
        resourceType: FontResourceType,
        status: FontStatus
    ) {
        self.name = name
        self.displayName = name.prettified()
        self.resourceType = resourceType
        self.status = status
    }
}

extension FontModel {

    public var sourceModel: FontSourceModel {
        .init(name: name, resourceType: resourceType)
    }
}

extension String {

    fileprivate func replacingRegexMatches(pattern: String, replaceWith: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch {
            print(error)
            return self
        }
    }

    fileprivate func prettified() -> String {
        var result = self.replacingOccurrences(of: "_", with: "-")
        result = result.replacingOccurrences(of: "-", with: " ")
        result = result.replacingRegexMatches(pattern: "([a-z])([A-Z])", replaceWith: "$1 $2")
        result = result.replacingRegexMatches(pattern: "([A-Z])([A-Z])([a-z])", replaceWith: "$1 $2$3")
        result = result.replacingRegexMatches(pattern: "([0-9])([a-zA-Z]{2})", replaceWith: "$1 $2$3")
        result = result.replacingRegexMatches(pattern: "([a-zA-Z])([0-9])", replaceWith: "$1 $2")
        return result
    }
}
