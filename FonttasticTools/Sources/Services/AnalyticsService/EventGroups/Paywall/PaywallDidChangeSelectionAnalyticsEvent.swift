//
//  PaywallDidChangeSelectionAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct PaywallDidChangeSelectionAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .paywall }
    public static var name: String { "didChangeSelection" }

    // MARK: - Instance Properties

    public let paywallItem: PaywallItem

    // MARK: - Initializers

    public init(paywallItem: PaywallItem) {
        self.paywallItem = paywallItem
    }

    // MARK: - Instance Methods

    public func makeParametersDictionary() -> [String: AnyHashable]? {
        return [
            "selectedPaywallItem": paywallItem
        ]
    }
}
