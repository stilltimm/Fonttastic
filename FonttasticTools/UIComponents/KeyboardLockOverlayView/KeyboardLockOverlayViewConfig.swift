//
//  KeyboardLockOverlayViewConfig.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 03.12.2021.
//

import Foundation
import UIKit

public struct KeyboardLockOverlayViewConfig {

    // MARK: - Instance Properties

    public let title: String
    public let message: String
    public let actionButtonTitle: String
    public let actionLinkURLString: String
}

extension KeyboardLockOverlayViewConfig {

    public init?(from appStatus: AppStatus) {
        switch (appStatus.appSubscriptionStatus, appStatus.keyboardInstallationStatus) {
        case (_, .installedWithLimitedAccess), (_, .notInstalled):
            self = .lockedDueToFullAccessLack

        case (.noSubscription, _):
            self = .lockedDueToNoActiveSubscription

        case (.hasActiveSubscription, .installedWithFullAccess):
            return nil
        }
    }
}

extension KeyboardLockOverlayViewConfig {

    static let lockedDueToNoActiveSubscription = KeyboardLockOverlayViewConfig(
        title: Strings.keyboardLockedStateTitle,
        message: Strings.keyboardLockedStateNoSubscriptionMessage,
        actionButtonTitle: Strings.keyboardLockedStateNoSubscriptionActionTitle,
        actionLinkURLString: "fonttastic://home"
    )

    static let lockedDueToFullAccessLack = KeyboardLockOverlayViewConfig(
        title: Strings.keyboardLockedStateTitle,
        message: Strings.keyboardLockedStateLimitedAccessMessage,
        actionButtonTitle: Strings.keyboardLockedStateLimitedAccessActionTitle,
        actionLinkURLString: UIApplication.openSettingsURLString
    )
}
