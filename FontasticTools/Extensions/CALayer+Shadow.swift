//
//  CALayer+Shadow.swift
//  FontasticTools
//
//  Created by Timofey Surkov on 02.10.2021.
//

import UIKit

extension CALayer {

    // MARK: - Nested Types

    public struct Shadow {
        let color: UIColor
        let alpha: Float
        let x: CGFloat
        let y: CGFloat
        let blur: CGFloat
        let spread: CGFloat

        public init(
            color: UIColor,
            alpha: Float,
            x: CGFloat,
            y: CGFloat,
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
        x: CGFloat,
        y: CGFloat,
        blur: CGFloat,
        spread: CGFloat
    ) {
        masksToBounds = false
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
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
}

extension CALayer.Shadow {

    public static let none = CALayer.Shadow(color: .clear, alpha: 0.0, x: 0, y: 0, blur: 0, spread: 0)
}
