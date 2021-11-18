//
//  AddFontNavigationController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit
import FonttasticTools

class AddFontNavigationController: BaseNavigationController {

    // MARK: - Nested Types

    enum AddFontSourceType {
        case parseFromImage(UIImage)
    }

    struct Context {
        let sourceType: AddFontSourceType
    }

    // MARK: - Private Properties

    private let newFontViewController: AddFontFromImageViewController

    private let context: Context

    // MARK: - Initializers

    init(context: Context) {
        self.context = context
        switch context.sourceType {
        case let .parseFromImage(image):
            self.newFontViewController = AddFontFromImageViewController(sourceImage: image)
        }

        super.init(rootViewController: newFontViewController)
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
