//
//  FontListViewController.swift
//  Fontastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit

class FontListViewController: UIViewController {

    // MARK: - Private Properties

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

        view.backgroundColor = Colors.backgroundMain
        navigationItem.title = Constants.title

        setupLayout()
    }

    // MARK: - Private Methods

    private func setupLayout() {

    }
}

private enum Constants {

    static let title = "Мои шрифты"
}
