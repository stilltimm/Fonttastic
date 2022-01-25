//
//  PaywallDidTapRestoreAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct PaywallDidTapRestoreAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .paywall }
    public static var name: String { "didTapRestore" }

    // MARK: - Initializers

    public init() {}
}
