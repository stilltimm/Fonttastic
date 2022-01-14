//
//  FontListDidAppearAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 22.12.2021.
//  Copyright © 2021 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct FontListDidAppearAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .fontList }
    public static var name: String { "didAppear" }

    // MARK: - Instance Properties

    public let willShowOnboarding: Bool

    // MARK: - Initializers

    public init(willShowOnboarding: Bool) {
        self.willShowOnboarding = willShowOnboarding
    }

    // MARK: - Instance Methods

    public func makeParametersDictionary() -> [String: AnyHashable]? {
        return [
            "willShowOnboarding": willShowOnboarding
        ]
    }
}
