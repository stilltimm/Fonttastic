//
//  Colors.swift
//  Fontastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit

private extension UIColor {

    convenience init(red: UInt32, green: UInt32, blue: UInt32) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: 1.0
        )
    }

    convenience init(hex: UInt32) {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        self.init(red: red, green: green, blue: blue)
    }
}

final class Colors {

    // MARK: - Public Type Properties

    static let brandMainLight: UIColor = UIColor(hex: 0x0032FC)

    static let brandMain: UIColor = makeDynamicColor(
        light: brandMainLight,
        dark: .white
    )
    static let brandMainInverted: UIColor = makeDynamicColor(
        light: .white,
        dark: brandMainLight
    )

    static let backgroundMain: UIColor = makeDynamicColor(
        light: UIColor(hex: 0xF8F9FF),
        dark: UIColor(hex: 0x000725)
    )
    static let backgroundMinor: UIColor = makeDynamicColor(
        light: UIColor(hex: 0xDFE5FF),
        dark: UIColor(hex: 0x141D44)
    )

    static let textMajor: UIColor = brandMain
    static let textMajorInverted: UIColor = brandMainInverted
    static let textMinor: UIColor = makeDynamicColor(
        light: UIColor(hex: 0x8099FF),
        dark: UIColor(hex: 0x707CAA)
    )

    static let keyboardButtonShadow: UIColor = UIColor(white: 0.5, alpha: 1.0)
    static let keyboardButtonMain: UIColor = .white
    static let keyboardButtonMainHighlighted: UIColor = UIColor(white: 0.98, alpha: 1.0)
    static let keyboardButtonMinor: UIColor = UIColor(white: 0.75, alpha: 1.0)

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
