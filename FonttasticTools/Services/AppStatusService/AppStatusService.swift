//
//  AppStatusService.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 02.12.2021.
//

import Foundation

public protocol AppStatusService: AnyObject {

    func getAppStatus(hasFullAccess: Bool?) -> AppStatus
}

enum AppStatusServiceError: Error {
    case appStatusDataNotFound
}

public class DefaultAppStatusService: AppStatusService {

    // MARK: - Public Type Properties

    public static let shared = DefaultAppStatusService()

    // MARK: - Initializers

    private init() {}

    // MARK: - Public Instance Properties

    public func getAppStatus(hasFullAccess: Bool?) -> AppStatus {
        let subscriptionStatus: AppSubscriptionStatus = hasActiveSubscription() ?
            .hasActiveSubscription :
            .noSubscription
        let keyboardStatus: KeyboardInstallationStatus
        if !isKeyboardInstalled() {
            keyboardStatus = .notInstalled
        } else {
            keyboardStatus = (hasFullAccess == true) ?
                .installedWithFullAccess :
                .installedWithLimitedAccess
        }

        return AppStatus(
            appSubscriptionStatus: subscriptionStatus,
            keyboardInstallationStatus: keyboardStatus
        )
    }

    // MARK: - Private Instance Methods

    private func isKeyboardInstalled() -> Bool {
        let defaultsDictionary = UserDefaults.standard.dictionaryRepresentation()
        guard let keyboardsArray = defaultsDictionary["AppleKeyboards"] as? [String] else {
            logger.log("Failed to get AppleKeyboards array from UserDefaults", level: .debug)
            return false
        }

        return keyboardsArray.contains(Constants.keyboardBundleID)
    }

    private func hasActiveSubscription() -> Bool {
        return false
    }
}

private enum Constants {

    static let appStatusKeychainContainerKey: String = "com.romandegtyarev.fonttastic.keychain.appStatus"
    static let keyboardBundleID: String = "com.romandegtyarev.fonttastic.fonttasticKeyboard"
}
