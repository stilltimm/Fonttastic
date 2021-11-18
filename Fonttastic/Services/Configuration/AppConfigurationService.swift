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
        configureFontsService()
    }

    private func configureLogger() {
        FonttasticLogger.shared.setup(with: .default)
    }

    private func configureFontsService() {
        fontsService.installFonts { }
    }
}
