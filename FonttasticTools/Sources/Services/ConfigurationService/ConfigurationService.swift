//
//  ConfigurationService.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 15.11.2021.
//

import Foundation
import RevenueCat

public enum Executable: UInt8 {

    case app
    case keyboardExtension
}

public protocol ConfigurationService {

    func performInitialConfigurations(for executable: Executable)
}

public class DefaultConfigurationService: ConfigurationService {

    // MARK: - Public Type Properties

    public static let shared = DefaultConfigurationService()

    // MARK: - Private Instance Properties

    private lazy var fontsService: FontsService = DefaultFontsService.shared
    private lazy var onboardingService: OnboardingService = DefaultOnboardingService.shared
    private lazy var subscriptionService: SubscriptionService = DefaultSubscriptionService.shared
    private lazy var analyticsService: AnalyticsService = DefaultAnalyticsService.shared
    private lazy var crashReportingService: BugReportsService = DefaultBugReportsService.shared

    // MARK: - Initializers

    private init() {}

    // MARK: - Public Instance Methods

    public func performInitialConfigurations(for executable: Executable) {
        performDefaultConfiguration(for: executable)

        if executable == .app, UserDefaults.standard.bool(forKey: Constants.isFirstLaunchKey) != true {
            UserDefaults.standard.set(true, forKey: Constants.isFirstLaunchKey)
            onboardingService.resetStoredState()
        }
    }

    // MARK: - Private Instance Methods

    private func performDefaultConfiguration(for executable: Executable) {
        FonttasticLogger.shared.setup(with: .default)
        analyticsService.configureAnalytics()
        crashReportingService.configureCrashReporting()
        configureFontsService()
        configureSubscriptionService(shouldFetchPaywall: executable == .app)
    }

    private func configureFontsService() {
        fontsService.installFonts {}
    }

    private func configureSubscriptionService(shouldFetchPaywall: Bool) {
        subscriptionService.configurePurchases()
        subscriptionService.fetchPurchaserInfo()
        if shouldFetchPaywall {
            subscriptionService.fetchPaywall(context: .initialAppConfiguration)
        }
    }
}

private enum Constants {

    static let isFirstLaunchKey: String = "com.romandegtyarev.fonttastic.isFirstLaunch"
}
