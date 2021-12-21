//
//  FontListNavigationController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit
import FonttasticTools

class FontListNavigationController: BaseNavigationController {

    // MARK: - Private Properties

    private let fontListViewController = FontListViewController(
        viewModel: FontListViewModel(mode: .fontsShowcase)
    )

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
