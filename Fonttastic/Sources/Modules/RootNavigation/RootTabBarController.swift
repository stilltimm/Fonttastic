//
//  RootTabBarController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit

class RootTabBarController: UITabBarController {

    // MARK: - Private Properties

    let fontListNavigationController = FontListNavigationController()

    #if DEBUG
    let keyboardTestNavigationController = KeyboardViewTestNavigationController()
    #endif

    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)

        setupRootControllers()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBarItems()

        tabBar.isHidden = true
    }

    // MARK: - Private Methods

    private func setupRootControllers() {
        let rootViewControllers: [UIViewController]
        #if DEBUG
        rootViewControllers = [
            fontListNavigationController,
            keyboardTestNavigationController
        ]
        #else
        rootViewControllers = [
            fontListNavigationController
        ]
        #endif
        self.setViewControllers(rootViewControllers, animated: false)
    }

    private func setupTabBarItems() {
        fontListNavigationController.tabBarItem = UITabBarItem(
            title: Constants.fontListTabBarItemTitle,
            image: UIImage(systemName: Constants.fontListTabBarItemIconName),
            selectedImage: UIImage(systemName: Constants.fontListTabBarItemSelectedIconName)
        )
        #if DEBUG
        keyboardTestNavigationController.tabBarItem = UITabBarItem(
            title: Constants.keyboardTabBarItemTitle,
            image: UIImage(systemName: Constants.keyboardTabBarItemIconName),
            selectedImage: UIImage(systemName: Constants.keyboardTabBarItemSelectedIconName)
        )
        #endif
    }
}

private enum Constants {

    static let fontListTabBarItemTitle = "Шрифты"
    static let fontListTabBarItemIconName = "folder"
    static let fontListTabBarItemSelectedIconName = "folder.fill"

    static let keyboardTabBarItemTitle = "Клавиатура"
    static let keyboardTabBarItemIconName = "keyboard"
    static let keyboardTabBarItemSelectedIconName = "keyboard.fill"
}
