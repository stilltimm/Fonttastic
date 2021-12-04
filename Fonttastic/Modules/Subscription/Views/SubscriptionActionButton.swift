//
//  SubscriptionActionButton.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 03.12.2021.
//

import UIKit
import Cartography
import FonttasticTools

class SubscriptionActionButton: UIButton {

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withConfig: .fastControl) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            }
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
        colors: [Colors.accentBackgroundTop, Colors.accentBackgroundBottom]
    )
}
