//
//  AppStatusService.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 02.12.2021.
//

import Foundation

public protocol AppStatusService: AnyObject {

    var appStatus: AppStatus { get }

    func setAppSubscriptionStatus(_ appSubscriptionStatus: AppSubscriptionStatus)
    func setKeyboardInstallationStatus(_ keyboardInstallationStatus: KeyboardInstallationStatus)
    func resetAppStatus()
}

enum AppStatusServiceError: Error {
    case appStatusDataNotFound
}

public class DefaultAppStatusService: AppStatusService {

    // MARK: - Public Type Properties

    public static let shared = DefaultAppStatusService()

    // MARK: - Private Type Methods

    private static func restoreAppStatus(from keychainContainer: KeychainContainer) throws -> AppStatus {
        guard let appStatusData = try keychainContainer.getData(for: Constants.appStatusKeychainContainerKey) else {
            throw AppStatusServiceError.appStatusDataNotFound
        }

        return try JSONDecoder().decode(AppStatus.self, from: appStatusData)
    }

    private static func storeAppStatus(
        _ appStatus: AppStatus,
        to keychainContainer: KeychainContainer
    ) throws {
        let appStatusData = try JSONEncoder().encode(appStatus)
        try keychainContainer.setData(appStatusData, for: Constants.appStatusKeychainContainerKey)
    }

    // MARK: - Public Instance Properties

    public var appStatus: AppStatus {
        didSet {
            do {
                try Self.storeAppStatus(appStatus, to: sharedKeychainContainer)
            } catch {
                logger.log(
                    "Got error saving AppStatus to Keychain",
                    description: "Error: \(error)",
                    level: .error
                )
            }
        }
    }

    // MARK: - Private Instance Properties

    private let keychainService: KeychainService
    private let sharedKeychainContainer: KeychainContainer

    // MARK: - Initializers

    private init() {
        self.keychainService = DefaultKeychainService.shared
        self.sharedKeychainContainer = keychainService.makeKeychainContainer(for: .sharedItems)

        do {
            self.appStatus = try Self.restoreAppStatus(from: sharedKeychainContainer)
            logger.log(
                "Successfully restored AppStatus",
                description: "AppStatus: \(appStatus)",
                level: .debug
            )
        } catch {
            logger.log(
                "Got error restoring AppStatus from Keychain",
                description: "Error: \(error)",
                level: .error
            )
            self.appStatus = .zero
        }
    }

    // MARK: - Public Instance Properties

    public func setAppSubscriptionStatus(_ appSubscriptionStatus: AppSubscriptionStatus) {
        self.appStatus = AppStatus(
            appSubscriptionStatus: appSubscriptionStatus,
            keyboardInstallationStatus: self.appStatus.keyboardInstallationStatus
        )
    }

    public func setKeyboardInstallationStatus(_ keyboardInstallationStatus: KeyboardInstallationStatus) {
        self.appStatus = AppStatus(
            appSubscriptionStatus: self.appStatus.appSubscriptionStatus,
            keyboardInstallationStatus: keyboardInstallationStatus
        )
    }

    public func resetAppStatus() {
        self.appStatus = .zero
    }
}

private enum Constants {

    static let appStatusKeychainContainerKey: String = "com.romandegtyarev.fonttastic.keychain.appStatus"
}
