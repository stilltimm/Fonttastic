//
//  SettingsNavigationController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit

class SettingsNavigationController: BaseNavigationController {

    // MARK: - Private Properties

    private let settingsViewController = SettingsViewController()

    // MARK: - Initializers

    init() {
        super.init(rootViewController: settingsViewController)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Setup Coordination logic
    }
}
