//
//  GradientView.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 04.12.2021.
//

import UIKit

public class LinearGradientView: UIView {

    // MARK: - Public Type Properties

    public override static var layerClass: AnyClass { CAGradientLayer.self }

    // MARK: - Public Instance Properties

    public var linearGradient: LinearGradient {
        didSet {
            updateGradientLayerStyle()
        }
    }

    // MARK: - Private Instance Properties

    private var gradientLayer: CAGradientLayer? {
        return layer as? CAGradientLayer
    }

    // MARK: - Initializers

    public init(linearGradient: LinearGradient) {
        self.linearGradient = linearGradient

        super.init(frame: .zero)

        setupGradientLayer()
        updateGradientLayerStyle()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Instance Methods

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else { return }

        gradientLayer?.colors = linearGradient.colors.map { $0.cgColor }
    }

    // MARK: - Private Instance Methods

    private func setupGradientLayer() {
        gradientLayer?.type = .axial
        gradientLayer?.startPoint = .zero
    }

    private func updateGradientLayerStyle() {
        gradientLayer?.endPoint = linearGradient.direction
        gradientLayer?.locations = linearGradient.locations.map { NSNumber(value: $0) }
        gradientLayer?.colors = linearGradient.colors.map { $0.cgColor }
    }
}
