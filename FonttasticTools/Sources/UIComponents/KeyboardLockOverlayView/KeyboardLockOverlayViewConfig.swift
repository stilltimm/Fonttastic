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
        switch (appStatus.subscriptionState, appStatus.keyboardInstallationState) {
        case (.noSubscription, _), (.hasInactiveSubscription, _):
            self = .lockedDueToNoActiveSubscription

        case (_, .notInstalled), (_, .installedWithLimitedAccess):
            self = .lockedDueToFullAccessLack

        default:
            return nil
        }
    }
}

extension KeyboardLockOverlayViewConfig {

    static let lockedDueToNoActiveSubscription = KeyboardLockOverlayViewConfig(
        title: FonttasticToolsStrings.Keyboard.LockedState.title,
        message: FonttasticToolsStrings.Keyboard.LockedState.NoSubscription.message,
        actionButtonTitle: FonttasticToolsStrings.Keyboard.LockedState.NoSubscription.actionTitle,
        actionLinkURLString: "fonttastic://home"
    )

    static let lockedDueToFullAccessLack = KeyboardLockOverlayViewConfig(
        title: FonttasticToolsStrings.Keyboard.LockedState.title,
        message: FonttasticToolsStrings.Keyboard.LockedState.LimitedAccess.message,
        actionButtonTitle: FonttasticToolsStrings.Keyboard.LockedState.LimitedAccess.actionTitle,
        actionLinkURLString: UIApplication.openSettingsURLString
    )
}
