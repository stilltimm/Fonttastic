//
//  AppConstants.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 15.12.2021.
//

import Foundation

public enum AppConstants {

    // MARK: - Public Type Properties

    public static let appGroupName: String = "group.88Q8M3ZBSJ.com.romandegtyarev.fonttastic"

    // MARK: - Internal Type Properties

    static let purchasesAPIKey: String? = ProcessInfo.processInfo.environment["PURCHASES_API_KEY"]
    static let amplitudeAPIKey: String? = ProcessInfo.processInfo.environment["AMPLITUDE_API_KEY"]
    static let bugsnagAPIKey: String? = ProcessInfo.processInfo.environment["BUGSNAG_API_KEY"]
}
