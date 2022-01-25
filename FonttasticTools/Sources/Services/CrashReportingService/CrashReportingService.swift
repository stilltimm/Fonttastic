//
//  BugReportsService.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 22.12.2021.
//  Copyright © 2021 com.romandegtyarev. All rights reserved.
//

import Foundation
import Bugsnag

public protocol BugReportsService {

    func configureCrashReporting()
    func trackError(error: Error)
}

public final class DefaultBugReportsService: BugReportsService {

    // MARK: - Type Properties

    public static let shared = DefaultBugReportsService()

    // MARK: - Public Instance Methods

    public func configureCrashReporting() {
        guard let bugsnagAPIKey = AppConstants.bugsnagAPIKey else {
            logger.error("Failed to configure crash reporting", description: "API key not found")
            return
        }

        Bugsnag.start(withApiKey: bugsnagAPIKey)
        logger.debug("Successfully configured crash reporting")
    }

    public func trackError(error: Error) {
        Bugsnag.notifyError(error)
    }
}
