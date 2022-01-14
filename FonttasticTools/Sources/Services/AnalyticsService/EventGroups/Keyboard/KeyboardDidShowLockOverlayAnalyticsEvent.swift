//
//  KeyboardDidShowLockOverlayAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct KeyboardDidShowLockOverlayAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .keyboard }
    public static var name: String { "didShowLockOverlay" }

    // MARK: - Instance Properties

    public let keyboardLockReason: KeyboardLockReason

    // MARK: - Initializers

    public init(keyboardLockReason: KeyboardLockReason) {
        self.keyboardLockReason = keyboardLockReason
    }

    // MARK: - Instance Methods

    public func makeParametersDictionary() -> [String: AnyHashable]? {
        return [
            "keyboardLockReason": keyboardLockReason
        ]
    }
}
