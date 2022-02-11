//
//  PaywallDidTapSubscribeAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct PaywallDidTapSubscribeAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .paywall }
    public static var name: String { "didTapSubscribe" }

    // MARK: - Instance Properties

    public let selectedPaywallItem: PaywallItem

    // MARK: - Initializers

    public init(selectedPaywallItem: PaywallItem) {
        self.selectedPaywallItem = selectedPaywallItem
    }

    // MARK: - Instance Methods

    public func makeParametersDictionary() -> [String: AnyHashable]? {
        return [
            "selectedPaywallItem": selectedPaywallItem
        ]
    }
}
