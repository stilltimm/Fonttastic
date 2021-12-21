//
//  AppConfigurationService.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 15.11.2021.
//

import Foundation
import FonttasticTools
import zlib
import RevenueCat

protocol AppConfigurationService {

    func configureApp()
}

class DefaultAppConfigurationService: AppConfigurationService {

    static let shared = DefaultAppConfigurationService()

    private lazy var fontsService: FontsService = DefaultFontsService.shared
    private lazy var onboardingService: OnboardingService = DefaultOnboardingService.shared
    private lazy var subscriptionService: SubscriptionService = DefaultSubscriptionService.shared

    private init() {}

    func configureApp() {
        performDefaultConfiguration()

        if UserDefaults.standard.bool(forKey: Constants.isFirstLaunchKey) != true {
            UserDefaults.standard.set(true, forKey: Constants.isFirstLaunchKey)
            performFirstLaunchConfiguration()
        }
    }

    // MARK: - Private Instance Methods

    private func performDefaultConfiguration() {
        configureLogger()
        configureFontsService()
        configureSubscriptionService()
    }

    private func configureLogger() {
        FonttasticLogger.shared.setup(with: .default)
    }

    private func configureFontsService() {
        fontsService.installFonts {}
    }

    private func configureSubscriptionService() {
        subscriptionService.configurePurchases()
        subscriptionService.fetchPurchaserInfo()
        subscriptionService.fetchAvailableProducts()
    }

    // MARK: - First Launch Setup

    private func performFirstLaunchConfiguration() {
        resetOnboardingState()
    }

    private func resetOnboardingState() {
        onboardingService.resetStoredState()
    }
}

private enum Constants {

    static let isFirstLaunchKey: String = "com.romandegtyarev.fonttastic.isFirstLaunch"
}
