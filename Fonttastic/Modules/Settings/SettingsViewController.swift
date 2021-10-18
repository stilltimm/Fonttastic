//
//  SettingsViewController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - Private Properties

    // TODO: Add image export settings

    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.backgroundMinor
        navigationItem.title = Constants.title

        setupLayout()
    }

    // MARK: - Private Methods

    private func setupLayout() {

    }
}

private enum Constants {

    static let title = "Настройки"
}
