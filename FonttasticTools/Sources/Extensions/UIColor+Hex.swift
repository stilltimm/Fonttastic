//
//  UIColor+Hex.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 16.11.2021.
//

import UIKit

extension UIColor {

    public convenience init(red: UInt32, green: UInt32, blue: UInt32) {
        self.init(
            red: CGFloat(red) / Constants.conversionMultiplier,
            green: CGFloat(green) / Constants.conversionMultiplier,
            blue: CGFloat(blue) / Constants.conversionMultiplier,
            alpha: 1.0
        )
    }

    public convenience init(hex: UInt32) {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        self.init(red: red, green: green, blue: blue)
    }

    public var hexValue: UInt32 {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        var result: UInt32 = 0
        result += UInt32(red * Constants.conversionMultiplier) << 16
        result += UInt32(green * Constants.conversionMultiplier) << 8
        result += UInt32(blue * Constants.conversionMultiplier)
        return result
    }
}

private enum Constants {

    static let conversionMultiplier: CGFloat = 255.0
}
