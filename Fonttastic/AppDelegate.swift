//
//  AppDelegate.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit
import FonttasticToolsStatic

let appLogger: FonttasticLogger = FonttasticLogger.shared

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /// NOTE: Retain static instance of FonttasticLogger for it to remain present until app termination
    private let logger: FonttasticLogger = FonttasticLogger.shared

    private lazy var appConfigurationService: AppConfigurationService = DefaultAppConfigurationService.shared

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        appConfigurationService.configureApp()
        setupRootWindow()

        return true
    }

    // MARK: - Window setup

    private func setupRootWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)

        let rootTabBarController = RootTabBarController()
        let rootNavigationController = RootNavigationController(rootViewController: rootTabBarController)
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()

        self.window = window
    }
}
