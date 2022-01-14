//
//  FontsServiceStartedInstallingFontsAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct FontsServiceStartedInstallingFontsAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .fontsService }
    public static var name: String { "startedInstallingFonts" }

    // MARK: - Initializers

    public init() {}
}
