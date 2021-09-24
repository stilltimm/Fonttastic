//
//  FontListNavigationController.swift
//  Fontastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit

class FontListNavigationController: BaseNavigationController {

    // MARK: - Private Properties

    private let fontListViewController = FontListViewController()

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

        // TODO: Setup Coordination logic
    }
}
