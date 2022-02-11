//
//  FontsServiceFinishedInstallingFontsAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

// swiftlint:disable:next type_name
public struct FontsServiceFinishedInstallingFontsAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .fontsService }
    public static var name: String { "finishedInstallingFonts" }

    // MARK: - Initializers

    public init() {}
}
