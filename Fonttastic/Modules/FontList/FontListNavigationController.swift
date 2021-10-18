//
//  FontListNavigationController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit

class FontListNavigationController: BaseNavigationController {

    // MARK: - Private Properties

    private let fontListViewController = FontListViewController(viewModel: .init())

    // MARK: - Initializers

    init() {
        super.init(rootViewController: fontListViewController)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
