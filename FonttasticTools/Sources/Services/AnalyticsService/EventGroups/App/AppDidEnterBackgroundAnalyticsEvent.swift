//
//  AppDidEnterBackgroundAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct AppDidEnterBackgroundAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .app }
    public static var name: String { "didEnterBackground" }

    // MARK: - Initializers

    public init() {}
}
