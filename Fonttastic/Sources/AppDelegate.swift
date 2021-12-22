//
//  AppDelegate.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit
import FonttasticTools

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /// NOTE: Retain static instance of FonttasticLogger for it to remain present until app termination
    private let logger: FonttasticLogger = FonttasticLogger.shared

    private lazy var configurationService: ConfigurationService = DefaultConfigurationService.shared
    private lazy var analyticsService: AnalyticsService = DefaultAnalyticsService.shared

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        configurationService.performInitialConfigurations(for: .app)
        setupRootWindow()

        analyticsService.trackEvent(AppStartedAnalyticsEvent())

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        DefaultFontsService.shared.storeLastUsedSettings()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: .shouldUpdateAppStatusNotification, object: nil)
    }

    // MARK: - Open URL handling

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return false }
        return components.scheme  == Constants.appScheme
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

private enum Constants {

    static let appScheme: String = "fonttastic"
}
