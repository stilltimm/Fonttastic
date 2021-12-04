//
//  Colors.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit

public final class Colors {

    // MARK: - Public Type Properties

    public static let blackAndWhite: UIColor = makeDynamicColor(light: .black, dark: .white)
    public static let whiteAndBlack: UIColor = makeDynamicColor(light: .white, dark: .black)

    public static let brandMainLight: UIColor = UIColor(hex: 0x0032FC)
    public static let brandMain: UIColor = makeDynamicColor(
        light: brandMainLight,
        dark: .white
    )
    public static let brandMainInverted: UIColor = makeDynamicColor(
        light: .white,
        dark: brandMainLight
    )

    public static let backgroundMain: UIColor = makeDynamicColor(
        light: UIColor(hex: 0xF8F9FF),
        dark: UIColor(hex: 0x000725)
    )
    public static let backgroundMinor: UIColor = makeDynamicColor(
        light: UIColor(hex: 0xDFE5FF),
        dark: UIColor(hex: 0x141D44)
    )
    public static let backgroundFocused: UIColor = makeDynamicColor(
        light: .white,
        dark: UIColor(hex: 0x18265D)
    )

    public static let titleMajor: UIColor = brandMain
    public static let titleMinor: UIColor = blackAndWhite

    public static let textMajor: UIColor = brandMain
    public static let textMajorInverted: UIColor = brandMainInverted
    public static let textMinor: UIColor = makeDynamicColor(
        light: UIColor(hex: 0xA6A6A6),
        dark: UIColor(hex: 0x707CAA)
    )

    public static let glassBackgroundTop: UIColor = makeDynamicColor(
        light: UIColor(white: 1, alpha: 0.6),
        dark: UIColor(white: 1, alpha: 0.18)
    )
    public static let glassBackgroundBottom: UIColor = makeDynamicColor(
        light: UIColor(white: 1, alpha: 0.2),
        dark: UIColor(white: 1, alpha: 0.05)
    )

    public static let accentBackgroundTop: UIColor = makeDynamicColor(
        light: UIColor(red: 0.494, green: 0, blue: 0.988, alpha: 1),
        dark: UIColor(red: 0.29, green: 0.345, blue: 0.898, alpha: 1)
    )
    public static let accentBackgroundBottom: UIColor = makeDynamicColor(
        light: UIColor(red: 0.988, green: 0, blue: 0.948, alpha: 0.2),
        dark: UIColor(red: 0.475, green: 0.341, blue: 0.922, alpha: 0.5)
    )

    // MARK: - Keyboard

    public static let keyboardButtonContent: UIColor = blackAndWhite
    public static let keyboardButtonShadow: UIColor = makeDynamicColor(
        light: UIColor(white: 0.6, alpha: 1.0),
        dark: UIColor(white: 0.11, alpha: 1.0)
    )
    public static let keyboardButtonMain: UIColor = makeDynamicColor(
        light: .white,
        dark: UIColor(white: 0.44, alpha: 1.0)
    )
    public static let keyboardButtonMainHighlighted: UIColor = makeDynamicColor(
        light: UIColor(white: 0.98, alpha: 1.0),
        dark: UIColor(white: 0.49, alpha: 1.0)
    )
    public static let keyboardButtonMinor: UIColor = makeDynamicColor(
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
