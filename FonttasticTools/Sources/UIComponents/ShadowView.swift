//
//  ShadowView.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 15.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import UIKit

public final class ShadowView: UIView {

    // MARK: - Type Properties

    private static let shadowCalculationsQueue = DispatchQueue(
        label: "com.romandegtyarev.shadowView.calculations",
        qos: .userInteractive,
        attributes: [.concurrent],
        autoreleaseFrequency: .workItem,
        target: nil
    )

    // MARK: - Subviews & Sublayers

    public let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.cornerCurve = .circular
        return view
    }()
    private let shadowContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private let shadowView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        view.layer.borderWidth = UIScreen.main.scale
        view.layer.borderColor = UIColor.clear.cgColor
        return view
    }()
    private let shadowMask: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillRule = .evenOdd
        return shapeLayer
    }()

    // MARK: - Instance Properties

    /// NOTE: These properties affect layout,
    /// and therefore implemented as stored properties with change tracking via `didSet {}`

    public var cornerRadius: CGFloat {
        didSet {
            guard !isPerformingUpdatesBatch, superview != nil else { return }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    public var shadowSpread: CGFloat {
        didSet {
            guard !isPerformingUpdatesBatch, superview != nil else { return }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    public var shadowRadius: CGFloat {
        didSet {
            guard !isPerformingUpdatesBatch, superview != nil else { return }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    public var shadowOffset: CGSize {
        didSet {
            guard !isPerformingUpdatesBatch, superview != nil else { return }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    /// NOTE: These properties do NOT affect layout,
    /// and therefore implemented as properties with  custom getter & setter

    public var shadowOpacity: Float {
        get { shadowView.layer.shadowOpacity }
        set { shadowView.layer.shadowOpacity = newValue }
    }
    public var shadowColor: UIColor? {
        get { shadowView.backgroundColor }
        set {
            shadowView.backgroundColor = newValue?.withAlphaComponent(CGFloat(shadowOpacity))
            shadowView.layer.shadowColor = newValue?.cgColor
        }
    }

    // MARK: - Other Instance Properties

    private var lastBounds: CGRect = .zero
    private var lastShadowSpread: CGFloat = .zero
    private var lastShadowRadius: CGFloat = .zero
    private var lastShadowOffset: CGSize = .zero
    private var lastCornerRadius: CGFloat = .zero

    private var isPerformingUpdatesBatch: Bool = false

    // MARK: - Init

    public init(
        cornerRadius: CGFloat = .zero,
        shadowSpread: CGFloat = .zero,
        shadowRadius: CGFloat = .zero,
        shadowOffset: CGSize = .zero,
        shadowOpacity: Float = 0,
        shadowColor: UIColor? = nil
    ) {
        self.cornerRadius = cornerRadius
        self.shadowSpread = shadowSpread
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset

        super.init(frame: .zero)

        self.shadowOpacity = shadowOpacity
        self.shadowColor = shadowColor

        self.clipsToBounds = false

        addSubview(shadowContainerView)
        shadowContainerView.addSubview(shadowView)
        addSubview(contentView)

        self.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: self.leftAnchor),
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.rightAnchor.constraint(equalTo: self.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    public convenience init(
        cornerRadius: CGFloat = .zero,
        shadow: Shadow = .none
    ) {
        self.init(
            cornerRadius: cornerRadius,
            shadowSpread: shadow.spread,
            shadowRadius: shadow.blur,
            shadowOffset: CGSize(width: shadow.x, height: shadow.y),
            shadowOpacity: shadow.alpha,
            shadowColor: shadow.color
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Instance Methods

    // swiftlint:disable:next function_body_length
    public override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds.width > 0 && bounds.height > 0 else { return }

        if
            bounds == lastBounds,
            shadowOffset == lastShadowOffset,
            shadowSpread == lastShadowSpread,
            lastShadowRadius == shadowRadius,
            cornerRadius == lastCornerRadius
        {
            return
        }

        lastBounds = bounds
        lastShadowOffset = shadowOffset
        lastShadowSpread = shadowSpread
        lastShadowRadius = shadowRadius
        lastCornerRadius = cornerRadius

        let _bounds = lastBounds
        let _shadowOffset = shadowOffset
        let _shadowSpread = shadowSpread
        let _shadowRadius = shadowRadius
        let _cornerRadius = cornerRadius
        let _cornerRadiusMultiplier = 3.0

        Self.shadowCalculationsQueue.async {
            let convertedShadowRadius = _shadowRadius * _cornerRadiusMultiplier
            let shadowContainerViewXOffset = -(_shadowSpread + convertedShadowRadius) + _shadowOffset.width
            let shadowContainerViewYOffset = -(_shadowSpread + convertedShadowRadius) + _shadowOffset.height
            let shadowContainerViewWidth = _bounds.width + 2 * (_shadowSpread + convertedShadowRadius)
            let shadowContainerViewHeight = _bounds.height + 2 * (_shadowSpread + convertedShadowRadius)
            let shadowContainerViewFrame = CGRect(
                x: shadowContainerViewXOffset,
                y: shadowContainerViewYOffset,
                width: shadowContainerViewWidth,
                height: shadowContainerViewHeight
            )
            let shadowRect = CGRect(
                x: convertedShadowRadius,
                y: convertedShadowRadius,
                width: _bounds.width + 2 * _shadowSpread,
                height: _bounds.height + 2 * _shadowSpread
            )
            let boundsCutoutRect = CGRect(
                x: convertedShadowRadius + _shadowSpread - _shadowOffset.width,
                y: convertedShadowRadius + _shadowSpread - _shadowOffset.height,
                width: _bounds.width,
                height: _bounds.height
            )

            let shadowPath: CGMutablePath = CGMutablePath()
            shadowPath.addRect(CGRect(
                x: 0,
                y: 0,
                width: shadowContainerViewWidth,
                height: shadowContainerViewHeight
            ))
            shadowPath.addPath(
                UIBezierPath(
                    roundedRect: boundsCutoutRect,
                    cornerRadius: _cornerRadius
                ).cgPath
            )

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.shadowContainerView.frame = shadowContainerViewFrame
                self.shadowView.frame = shadowRect

                self.shadowMask.path = shadowPath
                self.shadowContainerView.layer.mask = self.shadowMask

                self.contentView.layer.cornerRadius = _cornerRadius
                self.shadowView.layer.cornerRadius = _cornerRadius + _shadowSpread
                self.shadowView.layer.shadowRadius = _shadowRadius
                self.shadowView.layer.shadowColor = self.shadowColor?.cgColor
                self.shadowView.layer.shadowOpacity = self.shadowOpacity
            }
        }
    }

    public func apply(cornerRadius: CGFloat, shadow: Shadow?) {
        self.isPerformingUpdatesBatch = true

        let _shadow: Shadow = shadow ?? .none
        self.cornerRadius = cornerRadius
        self.shadowSpread = _shadow.spread
        self.shadowRadius = _shadow.blur
        self.shadowOffset = CGSize(width: _shadow.x, height: _shadow.y)
        self.shadowOpacity = _shadow.alpha
        self.shadowColor = _shadow.color

        self.isPerformingUpdatesBatch = false
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
