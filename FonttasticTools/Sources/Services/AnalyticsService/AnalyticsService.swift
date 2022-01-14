//
//  AnalyticsService.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 22.12.2021.
//  Copyright © 2021 com.romandegtyarev. All rights reserved.
//

import Foundation
import Amplitude

public protocol AnalyticsService: AnyObject {

    func configureAnalytics()
    func trackEvent(_ analyticsEvent: AnalyticsEvent)
}

public final class DefaultAnalyticsService: AnalyticsService {

    // MARK: - Public Type Properties

    public static let shared = DefaultAnalyticsService()

    // MARK: - Initializers

    private init() {}

    // MARK: - Public Instance Methods

    public func configureAnalytics() {
        Amplitude.instance().trackingSessionEvents = true

        guard let amplitudeAPIKey = AppConstants.amplitudeAPIKey else {
            logger.error("Failed to configure Analytics", description: "API Key not found")
            return
        }

        Amplitude.instance().initializeApiKey(amplitudeAPIKey)
//        Amplitude.instance().setServerZone(.EU)

        logger.debug("Successfully configured Analytics")
    }

    public func trackEvent(_ analyticsEvent: AnalyticsEvent) {
        let analyticsEventType: String = analyticsEvent.makeAnalyticsEventType()
        let eventProperties: [String: AnyHashable]? = analyticsEvent.makeParametersDictionary()
        Amplitude.instance().logEvent(
            analyticsEventType,
            withEventProperties: eventProperties
        )

        logger.debug(
            "Did track event \"\(analyticsEventType)\"",
            description: eventProperties?.debugDescription
        )
    }
}
