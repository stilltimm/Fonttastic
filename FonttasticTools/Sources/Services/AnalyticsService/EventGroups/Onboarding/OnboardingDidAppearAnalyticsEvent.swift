//
//  OnboardingDidAppearAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct OnboardingDidAppearAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .onboarding }
    public static var name: String { "didAppear" }

    // MARK: - Initializers

    public init() {}
}
