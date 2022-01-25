//
//  OnboardingDidChangePageAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct OnboardingDidChangePageAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .onboarding }
    public static var name: String { "didChangePage" }

    // MARK: - Instance Properties

    public let onboardingPage: OnboardingPage

    // MARK: - Initializers

    public init(onboardingPage: OnboardingPage) {
        self.onboardingPage = onboardingPage
    }

    // MARK: - Instance Methods

    public func makeParametersDictionary() -> [String: AnyHashable]? {
        return [
            "onboardingPage": onboardingPage.rawValue
        ]
    }
}
