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

    private init() {}

    func configureApp() {
        configureLogger()
        resetAppStatusIfNeeded()
        configureFontsService()
    }

    private func configureLogger() {
        FonttasticLogger.shared.setup(with: .default)
    }

    private func configureFontsService() {
        fontsService.installFonts { }
    }

    private func resetAppStatusIfNeeded() {
        if UserDefaults.standard.bool(forKey: Constants.isFirstLaunchKey) != true {
            UserDefaults.standard.set(true, forKey: Constants.isFirstLaunchKey)

            DefaultAppStatusService.shared.resetAppStatus()
        }
    }
}

private enum Constants {

    static let isFirstLaunchKey: String = "com.romandegtyarev.fonttastic.isFirstLaunch"
}
