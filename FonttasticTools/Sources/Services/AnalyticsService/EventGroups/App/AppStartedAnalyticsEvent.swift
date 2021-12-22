//
//  AppStartedAnalyticsEvent.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 22.12.2021.
//  Copyright © 2021 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct AppStartedAnalyticsEvent: AnalyticsEvent {

    public static var group: AnalyticsEventGroup { .app }
    public static var name: String { "started" }

    public init() {}
}
