//
//  NewFontNavigationController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit

class NewFontNavigationController: BaseNavigationController {

    // MARK: - Private Properties

    private let newFontViewController = NewFontViewController()

    // MARK: - Initializers

    init() {
        super.init(rootViewController: newFontViewController)
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
