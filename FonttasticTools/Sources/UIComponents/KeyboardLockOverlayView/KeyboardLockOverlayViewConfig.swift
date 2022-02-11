//
//  KeyboardLockOverlayViewConfig.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 03.12.2021.
//

import Foundation
import UIKit

public enum KeyboardLockReason: String {

    case lockedDueToNoActiveSubscription
    case lockedDueToFullAccessLack

    // MARK: - Initializers

    public init?(appStatus: AppStatus) {
        let isInstalledWithFullAccess = appStatus.keyboardInstallationState.isInstalledWithFullAccess
        let isSubscriptionActive = appStatus.subscriptionState.isSubscriptionActive
        switch (isInstalledWithFullAccess, isSubscriptionActive) {
        case (false, _):
            self = .lockedDueToFullAccessLack

        case (_, false):
            self = .lockedDueToNoActiveSubscription

        case (true, true):
            return nil
        }
    }
}

public struct KeyboardLockOverlayViewConfig {

    // MARK: - Instance Properties

    public let title: String
    public let message: String
    public let actionButtonTitle: String
    public let keyboardLockReason: KeyboardLockReason
}

extension KeyboardLockOverlayViewConfig {

    public init(from keyboardLockReason: KeyboardLockReason) {
        self.keyboardLockReason = keyboardLockReason
        self.title = FonttasticToolsStrings.Keyboard.LockedState.title

        switch keyboardLockReason {
        case .lockedDueToNoActiveSubscription:
            self.message = FonttasticToolsStrings.Keyboard.LockedState.NoSubscriptionInfo.message
            self.actionButtonTitle = FonttasticToolsStrings.Keyboard.LockedState.NoSubscriptionInfo.actionTitle

        case .lockedDueToFullAccessLack:
            self.message = FonttasticToolsStrings.Keyboard.LockedState.LimitedAccess.message
            self.actionButtonTitle = FonttasticToolsStrings.Keyboard.LockedState.LimitedAccess.actionTitle
        }
    }
}
