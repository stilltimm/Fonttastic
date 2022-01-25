//
//  KeyboardDidSelectBackgroundImageAnaltyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

// swiftlint:disable:next type_name
public struct KeyboardDidSelectBackgroundImageAnaltyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .keyboard }
    public static var name: String { "didSelectBackgroundImage" }

    // MARK: - Initializers

    public init() {}
}
