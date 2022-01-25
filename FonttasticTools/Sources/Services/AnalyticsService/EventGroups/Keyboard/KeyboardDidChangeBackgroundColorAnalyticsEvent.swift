//
//  KeyboardDidChangeBackgroundColorAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

// swiftlint:disable:next type_name
public struct KeyboardDidChangeBackgroundColorAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .keyboard }
    public static var name: String { "didChangeBackgroundColor" }

    // MARK: - Instance Properties

    public let colorHEX: String

    // MARK: - Initializers

    public init(colorHEX: String) {
        self.colorHEX = colorHEX
    }

    // MARK: - Instance Methods

    public func makeParametersDictionary() -> [String: AnyHashable]? {
        return [
            "color": colorHEX
        ]
    }
}
