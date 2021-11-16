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
        let config: FonttasticLogger.Config
        #if DEBUG
        config = FonttasticLogger.Config(
            enabledOutputs: [
                .console: Set(FonttasticLogger.LogLevel.allCases)
            ]
        )
        #elseif BETA
        config = FonttasticLogger.Config(
            enabledOutputs: [
                .osLog: [.error, .info]
            ]
        )
        #else
        config = FonttasticLogger.Config(
            enabledOutputs: [
                .analytics: [.error]
            ]
        )
        #endif
        FonttasticLogger.shared.setup(with: config)
    }

    private func configureFontsService() {
        fontsService.installFonts()
    }
}
