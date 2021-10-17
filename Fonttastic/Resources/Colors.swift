//
//  Colors.swift
//  Fonttastic
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
    static let backgroundFocused: UIColor = makeDynamicColor(
        light: .white,
        dark: UIColor(hex: 0x18265D)
    )

    static let titleMajor: UIColor = brandMain
    static let titleMinor: UIColor = blackAndWhite

    static let textMajor: UIColor = brandMain
    static let textMajorInverted: UIColor = brandMainInverted
    static let textMinor: UIColor = makeDynamicColor(
        light: UIColor(hex: 0xA6A6A6),
        dark: UIColor(hex: 0x707CAA)
    )

    static let blackAndWhite: UIColor = makeDynamicColor(light: .black, dark: .white)
    static let whiteAndBlack: UIColor = makeDynamicColor(light: .white, dark: .black)

    static let keyboardButtonContent: UIColor = blackAndWhite
    static let keyboardButtonShadow: UIColor = makeDynamicColor(
        light: UIColor(white: 0.6, alpha: 1.0),
        dark: UIColor(white: 0.11, alpha: 1.0)
    )
    static let keyboardButtonMain: UIColor = makeDynamicColor(
        light: .white,
        dark: UIColor(white: 0.44, alpha: 1.0)
    )
    static let keyboardButtonMainHighlighted: UIColor = makeDynamicColor(
        light: UIColor(white: 0.98, alpha: 1.0),
        dark: UIColor(white: 0.49, alpha: 1.0)
    )
    static let keyboardButtonMinor: UIColor = makeDynamicColor(
        light: UIColor(hex: 0xB3B6C0),
        dark: UIColor(white: 0.28, alpha: 1.0)
    )

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
