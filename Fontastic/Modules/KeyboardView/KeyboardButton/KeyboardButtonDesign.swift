//
//  KeyboardButtonDesign.swift
//  Fontastic
//
//  Created by Timofey Surkov on 03.10.2021.
//

import UIKit

enum KeyboardButtonLayoutStyle {

    case intrinsic(spacing: CGFloat)
    case fixed(width: CGFloat)
    case flexible(flexBasis: CGFloat)
}

struct KeyboardButtonDesign {

    let layoutWidth: KeyboardButtonLayoutStyle
    let layoutHeight: CGFloat

    let backgroundColor: UIColor
    let foregroundColor: UIColor
    let highlightedForegroundColor: UIColor

    let shadowSize: CGFloat
    let cornerRadius: CGFloat
    let labelFont: UIFont
    let iconSize: CGSize
}

class KeyboardButtonDesignBuilder {

    // MARK: - Private Instance Properties

    private let base: KeyboardButtonDesign

    private var layoutWidth: KeyboardButtonLayoutStyle
    private var backgroundColor: UIColor
    private var foregroundColor: UIColor
    private var highlightedForegroundColor: UIColor

    // MARK: - Initializers

    init(_ base: KeyboardButtonDesign) {
        self.base = base
        self.layoutWidth = base.layoutWidth
        self.backgroundColor = base.backgroundColor
        self.foregroundColor = base.foregroundColor
        self.highlightedForegroundColor = base.highlightedForegroundColor
    }

    // MARK: - Public Instance Methods

    func withLayoutWidth(_ value: KeyboardButtonLayoutStyle) -> Self {
        self.layoutWidth = value
        return self
    }
    func withBackgroundColor(_ value: UIColor) -> Self {
        self.backgroundColor = value
        return self
    }
    func withForegroungColor(_ value: UIColor) -> Self {
        self.foregroundColor = value
        return self
    }
    func withHighlightedForegroundColor(_ value: UIColor) -> Self {
        self.highlightedForegroundColor = value
        return self
    }
    func build() -> KeyboardButtonDesign {
        return KeyboardButtonDesign(
            layoutWidth: layoutWidth,
            layoutHeight: base.layoutHeight,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            highlightedForegroundColor: highlightedForegroundColor,
            shadowSize: base.shadowSize,
            cornerRadius: base.cornerRadius,
            labelFont: base.labelFont,
            iconSize: base.iconSize
        )
    }
}
