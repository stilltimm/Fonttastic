//
//  BaseNavigationController.swift
//  Fontastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        navigationBar.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 36.0, weight: .bold),
            .foregroundColor: Colors.textMajor
        ]

        view.backgroundColor = Colors.backgroundMinor
    }
}
