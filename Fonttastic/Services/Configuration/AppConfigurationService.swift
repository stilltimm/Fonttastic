//
//  AppConfigurationService.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 15.11.2021.
//

import Foundation
import FonttasticTools
import zlib

protocol AppConfigurationService {

    func configureApp()
}

class DefaultAppConfigurationService: AppConfigurationService {

    static let shared = DefaultAppConfigurationService()

    private lazy var fontsService: FontsService = DefaultFontsService.shared
    private lazy var appStatusService: AppStatusService = DefaultAppStatusService.shared

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
    }

    private func configureLogger() {
        FonttasticLogger.shared.setup(with: .default)
    }

    private func configureFontsService() {
        fontsService.installFonts { }
    }

    // MARK: - First Launch Setup

    private func performFirstLaunchConfiguration() {
        resetStoredState()
    }

    private func resetStoredState() {
        appStatusService.resetStoredState()
    }
}

private enum Constants {

    static let isFirstLaunchKey: String = "com.romandegtyarev.fonttastic.isFirstLaunch"
}
