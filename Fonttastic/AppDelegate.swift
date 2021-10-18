//
//  AppDelegate.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
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
