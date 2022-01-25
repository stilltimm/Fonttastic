//
//  KeyboardDidChangeTextColorAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct KeyboardDidChangeTextColorAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .keyboard }
    public static var name: String { "didChangeTextColor" }

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
