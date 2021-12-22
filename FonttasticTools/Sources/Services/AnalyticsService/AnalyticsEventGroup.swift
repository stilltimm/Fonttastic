//
//  AnalyticsEventGroup.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 22.12.2021.
//  Copyright © 2021 com.romandegtyarev. All rights reserved.
//

import Foundation

public enum AnalyticsEventGroup: String {

    // MARK: - App Related

    case app
    case onboarding
    case subscription
    case fontList
    case fontDetails

    // MARK: - Keyboard Related

    case keyboard

    // MARK: - General

    case log
}
