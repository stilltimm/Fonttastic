//
//  KeyboardViewTestNavigationController.swift
//  Fontastic
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit

class KeyboardViewTestNavigationController: BaseNavigationController {

    // MARK: - Private Properties

    private let keyboardTestViewController = KeyboardViewTestViewController()

    // MARK: - Initializers

    init() {
        super.init(rootViewController: keyboardTestViewController)
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
