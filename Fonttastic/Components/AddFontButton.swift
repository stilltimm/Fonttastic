//
//  AddFontButton.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 17.10.2021.
//

import UIKit
import FonttasticTools

class AddFontButton: UIButton {

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withConfig: .fastControl) {
                self.transform = self.isHighlighted ? .init(scaleX: 0.95, y: 0.95) : .identity
            }
        }
    }

    init() {
        super.init(frame: .zero)

        backgroundColor = Colors.brandMainLight
        let image = UIImage(named: "PlusIcon")
        setImage(image?.withTintColor(.white), for: .normal)
        setImage(
            image?.withTintColor(.white.withAlphaComponent(0.5)),
            for: .highlighted
        )
        imageView?.tintColor = .white
        contentMode = .scaleToFill
        layer.cornerRadius = 16.0
        layer.cornerCurve = .continuous
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
