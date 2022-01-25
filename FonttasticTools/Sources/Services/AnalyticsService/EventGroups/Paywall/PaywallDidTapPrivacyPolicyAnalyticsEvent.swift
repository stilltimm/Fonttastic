//
//  PaywallDidTapPrivacyPolicyAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 20.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct PaywallDidTapPrivacyPolicyAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .paywall }
    public static var name: String { "didTapPrivacyPolicy" }

    // MARK: - Initializers

    public init() {}
}
