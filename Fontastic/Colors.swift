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

    static let textMajor: UIColor = makeDynamicColor(light: .black, dark: .white)

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
