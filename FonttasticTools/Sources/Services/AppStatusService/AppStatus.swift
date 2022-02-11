//
//  AppStatus.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 02.12.2021.
//

import Foundation

public struct AppStatus {

    // MARK: - Instance Properties

    public let subscriptionState: SubscriptionState
    public let keyboardInstallationState: KeyboardInstallationState

    // MARK: - Public Instance Properties

    public var description: String {
        var result: String = "ℹ️ App Status:"
        result += "\n⌨️ Keyboard [\(keyboardInstallationState.description)]"
        result += "\n💰 Subscription [\(subscriptionState.description)]"
        return result
    }

    // MARK: - Initializers

    public init(
        subscriptionState: SubscriptionState,
        keyboardInstallationState: KeyboardInstallationState
    ) {
        self.subscriptionState = subscriptionState
        self.keyboardInstallationState = keyboardInstallationState
    }
}

extension AppStatus {

    public static let zero: AppStatus = AppStatus(
        subscriptionState: .noSubscriptionInfo,
        keyboardInstallationState: .notInstalled
    )
}
