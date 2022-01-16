//
//  KeyboardDidChangeTextAlignmentAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation
import UIKit

// swiftlint:disable:next type_name
public struct KeyboardDidChangeTextAlignmentAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .keyboard }
    public static var name: String { "didChangeTextAlignment" }

    // MARK: - Instance Properties

    public let textAlignment: NSTextAlignment

    // MARK: - Initializers

    public init(textAlignment: NSTextAlignment) {
        self.textAlignment = textAlignment
    }

    // MARK: - Instance Methods

    public func makeParametersDictionary() -> [String: AnyHashable]? {
        return [
            "textAlignment": textAlignment.description
        ]
    }
}

extension NSTextAlignment {

    var description: String {
        switch self {
        case .left:
            return "left"

        case .center:
            return "center"

        case .right:
            return "right"

        case .natural:
            return "natural"

        case .justified:
            return "justified"

        @unknown default:
            return "unknown"
        }
    }
}
