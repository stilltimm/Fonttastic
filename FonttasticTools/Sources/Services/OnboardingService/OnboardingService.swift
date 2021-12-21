//
//  OnboardingService.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 19.12.2021.
//

import Foundation

public protocol OnboardingService: AnyObject {

    func hasCompletedOnboarding() -> Bool
    func setOnboardingComplete()
    func resetStoredState()
}

public class DefaultOnboardingService: OnboardingService {

    // MARK: - Public Type Properties

    public static let shared = DefaultOnboardingService()

    // MARK: - Private Instance Properties

    private let keychainContainer = DefaultKeychainService.shared.makeKeychainContainer(for: .app)

    // MARK: - Initializers

    private init() {}

    // MARK: - Public Instance Properties

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
}

private enum Constants {

    static let onboardingCompletedKey: String = "com.romandegtyarev.fonttastic.keychain.onboardingCompleted"
    static let onboardingCompletedValue: String = "completed"
}
