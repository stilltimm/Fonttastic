//
//  PaywallDidStartLoadingAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct PaywallDidStartLoadingAnalyticsEvent: AnalyticsEvent {

    // MARK: - Nested Types

    public enum Context: String {

        case viewControllerLoaded
        case viewControllerReloadButtonTap
        case initialAppConfiguration
        case paywallItemPurchaseErrorOccured
    }

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .paywall }
    public static var name: String { "didStartLoading" }

    // MARK: - Instance Properties

    public let context: Context

    // MARK: - Initializers

    public init(context: Context) {
        self.context = context
    }

    // MARK: - Instance Methods

    public func makeParametersDictionary() -> [String: AnyHashable]? {
        return [
            "context": context.rawValue
        ]
    }
}
