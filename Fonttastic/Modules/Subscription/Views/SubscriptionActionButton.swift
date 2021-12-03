//
//  SubscriptionActionButton.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 03.12.2021.
//

import UIKit

class SubscriptionActionButton: UIButton {

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withConfig: .fastControl) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            }
        }
    }
}
