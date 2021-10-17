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
//    let keyboardTestNavigationController = KeyboardViewTestNavigationController()
//    let newFontNavigationController = NewFontNavigationController()
//    let settingsNavigationController = SettingsNavigationController()

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
        let rootViewControllers: [UIViewController] = [
            fontListNavigationController
//            keyboardTestNavigationController,
//            newFontNavigationController,
//            settingsNavigationController
        ]
        self.setViewControllers(rootViewControllers, animated: false)
    }

    private func setupTabBarItems() {
        fontListNavigationController.tabBarItem = UITabBarItem(
            title: Constants.fontListTabBarItemTitle,
            image: UIImage(systemName: Constants.fontListTabBarItemIconName),
            selectedImage: UIImage(systemName: Constants.fontListTabBarItemSelectedIconName)
        )
//        keyboardTestNavigationController.tabBarItem = UITabBarItem(
//            title: Constants.keyboardTabBarItemTitle,
//            image: UIImage(systemName: Constants.keyboardTabBarItemIconName),
//            selectedImage: UIImage(systemName: Constants.keyboardTabBarItemSelectedIconName)
//        )
//        newFontNavigationController.tabBarItem = UITabBarItem(
//            title: Constants.newFontTabBarItemTitle,
//            image: UIImage(systemName: Constants.newFontTabBarItemIconName),
//            selectedImage: UIImage(systemName: Constants.newFontTabBarItemSelectedIconName)
//        )
//        settingsNavigationController.tabBarItem = UITabBarItem(
//            title: Constants.settingsTabBarItemTitle,
//            image: UIImage(systemName: Constants.settingsTabBarItemIconName),
//            selectedImage: UIImage(systemName: Constants.settingsTabBarItemSelectedIconName)
//        )
    }
}

private enum Constants {

    static let fontListTabBarItemTitle = "Шрифты"
    static let fontListTabBarItemIconName = "folder"
    static let fontListTabBarItemSelectedIconName = "folder.fill"

    static let keyboardTabBarItemTitle = "Клавиатура"
    static let keyboardTabBarItemIconName = "keyboard"
    static let keyboardTabBarItemSelectedIconName = "keyboard.fill"

    static let newFontTabBarItemTitle = "Добавить"
    static let newFontTabBarItemIconName = "plus.circle"
    static let newFontTabBarItemSelectedIconName = "plus.circle.fill"

    static let settingsTabBarItemTitle = "Настройки"
    static let settingsTabBarItemIconName = "gearshape"
    static let settingsTabBarItemSelectedIconName = "gearshape.fill"
}
