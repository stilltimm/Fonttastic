//
//  CALayer+Shadow.swift
//  FontasticTools
//
//  Created by Timofey Surkov on 02.10.2021.
//

import UIKit

extension CALayer {

    // MARK: - Nested Types

    public struct Shadow: Equatable {
        let color: UIColor
        let alpha: Float
        let x: CGFloat // swiftlint:disable:this identifier_name
        let y: CGFloat // swiftlint:disable:this identifier_name
        let blur: CGFloat
        let spread: CGFloat

        public init(
            color: UIColor,
            alpha: Float,
            x: CGFloat, // swiftlint:disable:this identifier_name
            y: CGFloat, // swiftlint:disable:this identifier_name
            blur: CGFloat,
            spread: CGFloat
        ) {
            self.color = color
            self.alpha = alpha
            self.x = x
            self.y = y
            self.blur = blur
            self.spread = spread
        }
    }

    // MARK: - Public Instance Methods

    public func applyShadow(
        color: UIColor,
        alpha: Float,
        x: CGFloat, // swiftlint:disable:this identifier_name
        y: CGFloat, // swiftlint:disable:this identifier_name
        blur: CGFloat,
        spread: CGFloat
    ) {
        masksToBounds = false
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / Constants.blurMultiplier
        if spread == 0 {
            shadowPath = nil
        } else {
            let rect = CGRect(
                origin: CGPoint(x: -spread, y: -spread),
                size: CGSize(
                    width: max(bounds.width + 2 * spread, 1),
                    height: max(bounds.height + 2 * spread, 1)
                )
            )
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }

    public func applyShadow(_ shadow: Shadow) {
        self.applyShadow(
            color: shadow.color,
            alpha: shadow.alpha,
            x: shadow.x,
            y: shadow.y,
            blur: shadow.blur,
            spread: shadow.spread
        )
    }

    public func clearShadow() {
        self.shadowPath = nil
        self.shadowColor = nil
        self.shadowOffset = .zero
        self.shadowRadius = .zero
        self.shadowOpacity = .zero
    }

    public var shadow: Shadow {
        get {
            let spread: CGFloat
            if let shadowPath = self.shadowPath, !shadowPath.isEmpty {
                spread = -shadowPath.boundingBox.origin.x
            } else {
                spread = 0
            }
            return .init(
                color: UIColor(cgColor: shadowColor ?? UIColor.clear.cgColor),
                alpha: shadowOpacity,
                x: shadowOffset.width,
                y: shadowOffset.height,
                blur: shadowRadius * Constants.blurMultiplier,
                spread: spread
            )
        }
        set {
            applyShadow(newValue)
        }
    }
}

extension CALayer.Shadow {

    public static let none = CALayer.Shadow(color: .clear, alpha: 0.0, x: 0, y: 0, blur: 0, spread: 0)
}

private enum Constants {

    static let blurMultiplier: CGFloat = 2.0
}
