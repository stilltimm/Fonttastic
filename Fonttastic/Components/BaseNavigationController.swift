//
//  BaseNavigationController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit
import FonttasticToolsStatic

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        navigationBar.titleTextAttributes = [
            .font: UIFont(name: "Georgia-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: Colors.textMajor
        ]
        navigationBar.largeTitleTextAttributes = [
            .font: UIFont(name: "Georgia-Bold", size: 48) ?? UIFont.systemFont(ofSize: 48, weight: .bold),
            .foregroundColor: Colors.textMajor
        ]

        navigationBar.shadowImage = UIImage()
        view.backgroundColor = Colors.backgroundMain
    }
}
