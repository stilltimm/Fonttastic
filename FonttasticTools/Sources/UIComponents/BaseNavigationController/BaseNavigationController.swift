//
//  BaseNavigationController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit
import Cartography

open class BaseNavigationController: UINavigationController {

    private let backgroundView: UIView = {
        let imageView = UIImageView(image: FonttasticToolsAsset.bg.image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.titleTextAttributes = [
            .font: UIFont(name: "AvenirNext-Medium", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: Colors.blackAndWhite
        ]
        navigationBar.isTranslucent = true

        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)

        constrain(view, backgroundView) { view, background in
            background.edges == view.edges
        }
    }
}
