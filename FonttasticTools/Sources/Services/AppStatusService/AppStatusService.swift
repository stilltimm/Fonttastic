//
//  AppStatusService.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 02.12.2021.
//

import Foundation

public protocol AppStatusService: AnyObject {

    var appStatus: AppStatus { get }
    var appStatusDidUpdateEvent: HotEvent<AppStatus> { get }

    func setHasFullAccess(hasFullAccess: Bool)
}

enum AppStatusServiceError: Error {
    case appStatusDataNotFound
}

public class DefaultAppStatusService: AppStatusService {

    // MARK: - Private Type Methods

    private static func makeAppStatus(
        subscriptionState: SubscriptionState,
        hasFullAccess: Bool?
    ) -> AppStatus {
        let keyboardStatus: KeyboardInstallationState
        if !isKeyboardInstalled() {
            keyboardStatus = .notInstalled
        } else {
            keyboardStatus = (hasFullAccess == true) ?
                .installedWithFullAccess :
                .installedWithLimitedAccess
        }

        return AppStatus(
            subscriptionState: subscriptionState,
            keyboardInstallationState: keyboardStatus
        )
    }

    private static func isKeyboardInstalled() -> Bool {
        let defaultsDictionary = UserDefaults.standard.dictionaryRepresentation()
        guard let keyboardsArray = defaultsDictionary["AppleKeyboards"] as? [String] else {
            logger.log("Failed to get AppleKeyboards array from UserDefaults", level: .debug)
            return false
        }

        return keyboardsArray.contains(Constants.keyboardBundleID)
    }

    // MARK: - Public Type Properties

    public static let shared = DefaultAppStatusService()

    // MARK: - Public Instance Properties

    public private(set) var appStatus: AppStatus {
        didSet {
            logger.log("AppStatus changed to \(appStatus)", level: .debug)
            appStatusDidUpdateEvent.onNext(appStatus)
        }
    }
    public let appStatusDidUpdateEvent: HotEvent<AppStatus>

    // MARK: - Private Instance Properties

    private let subscriptionService: SubscriptionService = DefaultSubscriptionService.shared
    private var hasFullAccess: Bool?

    // MARK: - Initializers

    private init() {
        let initialAppStatus = Self.makeAppStatus(subscriptionState: .undefined, hasFullAccess: nil)
        self.appStatus = initialAppStatus
        self.appStatusDidUpdateEvent = HotEvent<AppStatus>(value: initialAppStatus)

        subscriptionService.subscriptionStateDidChangeEvent.subscribe(self) { [weak self] subscriptionState in
            guard let self = self else { return }
            self.appStatus = Self.makeAppStatus(
                subscriptionState: subscriptionState,
                hasFullAccess: self.hasFullAccess
            )
        }
    }

    // MARK: - Public Instance Properties

    public func setHasFullAccess(hasFullAccess: Bool) {
        self.hasFullAccess = hasFullAccess
        self.appStatus = Self.makeAppStatus(
            subscriptionState: subscriptionService.subscriptionState,
            hasFullAccess: hasFullAccess
        )
    }
}

private enum Constants {

    static let keyboardBundleID: String = "com.romandegtyarev.fonttastic.fonttasticKeyboard"
}
