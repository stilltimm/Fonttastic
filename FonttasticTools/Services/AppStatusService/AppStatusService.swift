//
//  AppStatusService.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 02.12.2021.
//

import Foundation

public protocol AppStatusService: AnyObject {

    func getAppStatus(hasFullAccess: Bool?) -> AppStatus
    func hasCompletedOnboarding() -> Bool
    func setOnboardingComplete()
    func resetStoredState()
}

enum AppStatusServiceError: Error {
    case appStatusDataNotFound
}

public class DefaultAppStatusService: AppStatusService {

    // MARK: - Public Type Properties

    public static let shared = DefaultAppStatusService()

    // MARK: - Private Instance Properties

    private let keychainContainer = DefaultKeychainService.shared.makeKeychainContainer(for: .app)

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

    public func hasCompletedOnboarding() -> Bool {
        do {
            let onboardingCompletedString = try keychainContainer.getString(for: Constants.onboardingCompletedKey)
            return onboardingCompletedString == Constants.onboardingCompletedValue
        } catch {
            logger.log(
                "Got error checking if onboarding completed",
                description: "Error: \(error)",
                level: .error
            )
        }

        return false
    }

    public func setOnboardingComplete() {
        do {
            try keychainContainer.setString(Constants.onboardingCompletedValue, for: Constants.onboardingCompletedKey)
        } catch {
            logger.log(
                "Got error setting onboarding completed",
                description: "Error: \(error)",
                level: .error
            )
        }
    }

    public func resetStoredState() {
        do {
            try keychainContainer.removeItem(for: Constants.onboardingCompletedKey)
        } catch {
            logger.log(
                "Got error resetting stored state",
                description: "Error: \(error)",
                level: .error
            )
        }
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
        return true
    }
}

private enum Constants {

    static let onboardingCompletedKey: String = "com.romandegtyarev.fonttastic.keychain.onboardingCompleted"
    static let onboardingCompletedValue: String = "completed"
    static let keyboardBundleID: String = "com.romandegtyarev.fonttastic.fonttasticKeyboard"
}
