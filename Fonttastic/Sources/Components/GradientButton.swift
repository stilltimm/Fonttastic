//
//  GradientButton.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 03.12.2021.
//

import UIKit
import Cartography
import FonttasticTools

class GradientButton: ShadowButton {

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withConfig: .fastControl) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            }
        }
    }

    var cornerRadius: CGFloat = 0 {
        didSet {
            gradientView.layer.cornerRadius = cornerRadius
        }
    }

    private let gradientView = LinearGradientView(linearGradient: .actionButton)

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        self.backgroundColor = .clear

        addSubview(gradientView)
        gradientView.clipsToBounds = true
        gradientView.isUserInteractionEnabled = false
        self.sendSubviewToBack(gradientView)

        constrain(self, gradientView) { view, gradientView in
            gradientView.edges == view.edges
        }
    }
}

private extension LinearGradient {

    static let actionButton = LinearGradient(
        direction: CGPoint(x: 0, y: 1),
        locations: [0, 1],
        colors: [
            UIColor(red: 0.968, green: 0, blue: 0.988, alpha: 1),
            UIColor(red: 0.42, green: 0, blue: 0.75, alpha: 1)
        ]
    )
}
