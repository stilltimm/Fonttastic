//
//  BaseNavigationController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit

open class BaseNavigationController: UINavigationController {

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        navigationBar.titleTextAttributes = [
            .font: UIFont(name: "Avenir Next", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: Colors.blackAndWhite
        ]

        navigationBar.shadowImage = UIImage()
        view.backgroundColor = Colors.backgroundMain
    }
}
