//
//  AppStatusChangedAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct AppStatusChangedAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .app }
    public static var name: String { "statusChanged" }

    // MARK: - Instance Properties

    public let appStatus: AppStatus

    // MARK: - Initializers

    public init(appStatus: AppStatus) {
        self.appStatus = appStatus
    }

    // MARK: - Instance Methods

    public func makeParametersDictionary() -> [String: AnyHashable]? {
        return [
            "keyboardInstallationState": appStatus.keyboardInstallationState.rawValue,
            "subscriptionState": appStatus.subscriptionState.debugDescription
        ]
    }
}
