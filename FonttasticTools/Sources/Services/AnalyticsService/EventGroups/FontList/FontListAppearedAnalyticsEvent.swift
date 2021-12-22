//
//  FontListDidAppearAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 22.12.2021.
//  Copyright © 2021 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct FontListDidAppearAnalyticsEvent: AnalyticsEvent {

    public static var group: AnalyticsEventGroup { .fontList }
    public static var name: String { "didAppear" }

    public let willShowOnboarding: Bool

    public var parametersDictionary: [String: AnyHashable]? {
        [
            "willShowOnboarding": willShowOnboarding
        ]
    }

    public init(willShowOnboarding: Bool) {
        self.willShowOnboarding = willShowOnboarding
    }
}
