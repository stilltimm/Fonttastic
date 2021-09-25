//
//  Colors.swift
//  Fontastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit

final class Colors {

    // MARK: - Public Type Properties

    static let backgroundMain: UIColor = makeDynamicColor(light: .white, dark: .black)
    static let backgroundMinor: UIColor = makeDynamicColor(
        light: UIColor(white: 0.95, alpha: 1.0),
        dark: UIColor(white: 0.05, alpha: 1.0)
    )

    static let textMajor: UIColor = makeDynamicColor(light: .black, dark: .white)
    static let textMinor: UIColor = makeDynamicColor(light: .darkGray, dark: .lightGray)

    // MARK: - Private Type Methods

    private static func makeDynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return dark

            case .light, .unspecified:
                return light

            @unknown default:
                return light
            }
        }
    }
}
