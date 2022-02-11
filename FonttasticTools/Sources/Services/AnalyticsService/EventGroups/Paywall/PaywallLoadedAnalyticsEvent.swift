//
//  PaywallLoadedAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct PaywallLoadedAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .paywall }
    public static var name: String { "loaded" }

    // MARK: - Instance Properties

    public let paywall: Paywall

    // MARK: - Initializers

    public init(paywall: Paywall) {
        self.paywall = paywall
    }

    // MARK: - Instance Methods

    public func makeParametersDictionary() -> [String: AnyHashable]? {
        return [
            "offeringIdentifier": paywall.offeringIdentifier,
            "isConsideredTrial": paywall.isTrial,
            "availableItems": paywall.items,
            "initiallySelectedPaywallItem": paywall.initiallySelectedItem
        ]
    }
}
