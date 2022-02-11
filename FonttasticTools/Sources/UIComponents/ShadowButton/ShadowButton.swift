//
//  ShadowButton.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 22.12.2021.
//  Copyright © 2021 com.romandegtyarev. All rights reserved.
//

import Foundation
import UIKit

open class ShadowButton: UIButton {

    // MARK: - Private Instance Properties

    private var shadow: Shadow? {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    private var shadowLayer: CALayer?

    // MARK: - Open Instance Methods

    open override func layoutSubviews() {
        super.layoutSubviews()

        updateShadowLayer()
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else { return }

        if self.shadow != nil {
            updateShadowLayer()
        }
    }

    // MARK: - Public Instance Methods

    public final func applyShadow(_ shadow: Shadow?) {
        self.shadow = shadow
    }

    // MARK: - Private Instance Methods

    private func updateShadowLayer() {
        if let shadow = self.shadow {
            let shadowLayer: CALayer
            if let layer = self.shadowLayer {
                shadowLayer = layer
            } else {
                shadowLayer = CALayer()
                layer.insertSublayer(shadowLayer, at: 0)
                self.shadowLayer = shadowLayer
                shadowLayer.applyShadow(shadow)
            }
            shadowLayer.frame = self.bounds
            shadowLayer.applyShadow(shadow)
            shadowLayer.isHidden = false
        } else {
            self.shadowLayer?.isHidden = true
        }
    }
}
