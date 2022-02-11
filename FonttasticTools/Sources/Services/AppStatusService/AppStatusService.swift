//
//  AppStatusService.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 02.12.2021.
//

import Foundation
import UIKit

public protocol AppStatusService: AnyObject {

    var appStatus: AppStatus { get }
    var appStatusDidUpdateEvent: HotEvent<AppStatus> { get }

    func setHasFullAccess(hasFullAccess: Bool)
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
            logger.debug("Failed to get AppleKeyboards array from UserDefaults")
            return false
        }

        return keyboardsArray.contains(Constants.keyboardBundleID)
    }

    // MARK: - Public Type Properties

    public static let shared = DefaultAppStatusService()

    // MARK: - Public Instance Properties

    public private(set) var appStatus: AppStatus {
        didSet {
            logger.debug("AppStatus changed to \(appStatus)")
            appStatusDidUpdateEvent.onNext(appStatus)
            analyticsService.trackEvent(AppStatusChangedAnalyticsEvent(appStatus: appStatus))
        }
    }
    public let appStatusDidUpdateEvent: HotEvent<AppStatus>

    // MARK: - Private Instance Properties

    private lazy var subscriptionService: SubscriptionService = DefaultSubscriptionService.shared
    private lazy var analyticsService: AnalyticsService = DefaultAnalyticsService.shared

    private var hasFullAccess: Bool?

    // MARK: - Initializers

    private init() {
        let initialAppStatus = Self.makeAppStatus(subscriptionState: .loading, hasFullAccess: nil)
        self.appStatus = initialAppStatus
        self.appStatusDidUpdateEvent = HotEvent<AppStatus>(value: initialAppStatus)

        subscribeToAppStateUpdates()
        subscribeToSubscriptionStateChanges()
    }

    // MARK: - Public Instance Properties

    public func setHasFullAccess(hasFullAccess: Bool) {
        self.hasFullAccess = hasFullAccess
        self.appStatus = Self.makeAppStatus(
            subscriptionState: subscriptionService.subscriptionState,
            hasFullAccess: hasFullAccess
        )
    }

    // MARK: - Private Instance Methods

    private func subscribeToSubscriptionStateChanges() {
        subscriptionService.subscriptionStateDidChangeEvent.subscribe(self) { [weak self] subscriptionState in
            guard let self = self else { return }
            self.appStatus = Self.makeAppStatus(
                subscriptionState: subscriptionState,
                hasFullAccess: self.hasFullAccess
            )
        }
    }

    private func subscribeToAppStateUpdates() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleAppDidBecomeActive),
            name: .shouldUpdateAppStatusNotification,
            object: nil
        )
    }

    @objc private func handleAppDidBecomeActive() {
        self.appStatus = Self.makeAppStatus(
            subscriptionState: subscriptionService.subscriptionState,
            hasFullAccess: hasFullAccess
        )
    }
}

extension Notification.Name {

    public static let shouldUpdateAppStatusNotification = Notification.Name(
        rawValue: "com.romandegtyarev.fonttastic.notification.shouldUpdateAppStatusNotification"
    )
}

private enum Constants {

    static let keyboardBundleID: String = "com.romandegtyarev.fonttastic.fonttasticKeyboard"
}
