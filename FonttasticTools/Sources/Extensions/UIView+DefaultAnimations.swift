//
//  UIView+DefaultAnimations.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 03.12.2021.
//

import Foundation
import UIKit

extension UIView {

    public struct SpringAnimationConfig {

        public let duration: TimeInterval
        public let delay: TimeInterval
        public let damping: CGFloat
        public let initialSpringVelocity: CGFloat
        public let options: AnimationOptions

        public init(
            duration: TimeInterval,
            delay: TimeInterval = 0,
            usingSpringWithDamping damping: CGFloat,
            initialSpringVelocity: CGFloat = 0,
            options: AnimationOptions = []
        ) {
            self.duration = duration
            self.delay = delay
            self.damping = damping
            self.initialSpringVelocity = initialSpringVelocity
            self.options = options
        }
    }

    public static func animate(
        withConfig config: SpringAnimationConfig,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        UIView.animate(
            withDuration: config.duration,
            delay: config.delay,
            usingSpringWithDamping: config.damping,
            initialSpringVelocity: config.initialSpringVelocity,
            options: config.options,
            animations: animations,
            completion: completion
        )
    }
}

extension UIView.SpringAnimationConfig {

    public static let fastControl: UIView.SpringAnimationConfig = UIView.SpringAnimationConfig(
        duration: 0.25,
        usingSpringWithDamping: 0.8
    )
}
