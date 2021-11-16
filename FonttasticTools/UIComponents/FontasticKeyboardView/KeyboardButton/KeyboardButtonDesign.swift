//
//  KeyboardButtonDesign.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 03.10.2021.
//

import UIKit
import AudioToolbox

public enum KeyboardButtonLayoutStyle {

    case intrinsic(spacing: CGFloat)
    case fixed(width: CGFloat)
}

public struct KeyboardButtonDesign {

    public let layoutWidth: KeyboardButtonLayoutStyle
    public let layoutHeight: CGFloat

    public let backgroundColor: UIColor
    public let foregroundColor: UIColor
    public let highlightedForegroundColor: UIColor

    public let shadowSize: CGFloat
    public let cornerRadius: CGFloat
    public let labelFont: UIFont
    public let iconSize: CGSize
    public let touchOutset: UIEdgeInsets
    public let isMagnificationEnabled: Bool

    public let pressSoundID: SystemSoundID?
}

public class KeyboardButtonDesignBuilder {

    // MARK: - Private Instance Properties

    private let base: KeyboardButtonDesign

    private var layoutWidth: KeyboardButtonLayoutStyle
    private var backgroundColor: UIColor
    private var foregroundColor: UIColor
    private var highlightedForegroundColor: UIColor
    private var labelFont: UIFont
    private var iconSize: CGSize
    private var touchOutset: UIEdgeInsets
    private var isMagnificationEnabled: Bool
    private var pressSoundID: SystemSoundID?

    // MARK: - Initializers

    public init(_ base: KeyboardButtonDesign) {
        self.base = base
        self.layoutWidth = base.layoutWidth
        self.backgroundColor = base.backgroundColor
        self.foregroundColor = base.foregroundColor
        self.highlightedForegroundColor = base.highlightedForegroundColor
        self.labelFont = base.labelFont
        self.iconSize = base.iconSize
        self.touchOutset = base.touchOutset
        self.isMagnificationEnabled = base.isMagnificationEnabled
        self.pressSoundID = base.pressSoundID
    }

    // MARK: - Public Instance Methods

    public func withLayoutWidth(_ value: KeyboardButtonLayoutStyle) -> Self {
        self.layoutWidth = value
        return self
    }
    public func withBackgroundColor(_ value: UIColor) -> Self {
        self.backgroundColor = value
        return self
    }
    public func withForegroungColor(_ value: UIColor) -> Self {
        self.foregroundColor = value
        return self
    }
    public func withHighlightedForegroundColor(_ value: UIColor) -> Self {
        self.highlightedForegroundColor = value
        return self
    }
    public func withLabelFont(_ value: UIFont) -> Self {
        self.labelFont = value
        return self
    }
    public func withIconSize(_ value: CGSize) -> Self {
        self.iconSize = value
        return self
    }
    public func withTouchOutset(_ value: UIEdgeInsets) -> Self {
        self.touchOutset = value
        return self
    }
    public func withIsMagnificationEnabled(_ value: Bool) -> Self {
        self.isMagnificationEnabled = value
        return self
    }
    public func withPressSoundID(_ value: SystemSoundID?) -> Self {
        self.pressSoundID = value
        return self
    }
    public func build() -> KeyboardButtonDesign {
        return KeyboardButtonDesign(
            layoutWidth: layoutWidth,
            layoutHeight: base.layoutHeight,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            highlightedForegroundColor: highlightedForegroundColor,
            shadowSize: base.shadowSize,
            cornerRadius: base.cornerRadius,
            labelFont: labelFont,
            iconSize: iconSize,
            touchOutset: touchOutset,
            isMagnificationEnabled: isMagnificationEnabled,
            pressSoundID: pressSoundID
        )
    }
}

extension KeyboardButtonDesign {

    static func `default`(fixedWidth: CGFloat, touchOutset: UIEdgeInsets) -> KeyboardButtonDesign {
        KeyboardButtonDesign(
            layoutWidth: .fixed(width: fixedWidth),
            layoutHeight: 43,
            backgroundColor: Colors.keyboardButtonShadow,
            foregroundColor: Colors.keyboardButtonMain,
            highlightedForegroundColor: Colors.keyboardButtonMainHighlighted,
            shadowSize: 1,
            cornerRadius: 5.0,
            labelFont: UIFont.systemFont(ofSize: 24, weight: .regular),
            iconSize: .init(width: 24.0, height: 24.0),
            touchOutset: touchOutset,
            isMagnificationEnabled: true,
            pressSoundID: Sounds.defaultKeyPress
        )
    }
}
