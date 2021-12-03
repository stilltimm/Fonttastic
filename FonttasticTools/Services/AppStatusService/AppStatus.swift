//
//  AppStatus.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 02.12.2021.
//

import Foundation

public enum AppSubscriptionStatus: UInt8, Codable {

    case noSubscription
    case hasActiveSubscription
}

public enum KeyboardInstallationStatus: UInt8, Codable {

    case notInstalled
    case installedWithLimitedAccess
    case installedWithFullAccess
}

public struct AppStatus: Codable {

    // MARK: - Instance Properties

    public let appSubscriptionStatus: AppSubscriptionStatus
    public let keyboardInstallationStatus: KeyboardInstallationStatus

    // MARK: - Initializers

    public init(
        appSubscriptionStatus: AppSubscriptionStatus,
        keyboardInstallationStatus: KeyboardInstallationStatus
    ) {
        self.appSubscriptionStatus = appSubscriptionStatus
        self.keyboardInstallationStatus = keyboardInstallationStatus
    }
}

extension AppStatus {

    public static let zero: AppStatus = AppStatus(
        appSubscriptionStatus: .noSubscription,
        keyboardInstallationStatus: .notInstalled
    )
}
