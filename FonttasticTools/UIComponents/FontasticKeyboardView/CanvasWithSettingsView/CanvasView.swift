//
//  CanvasView.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 04.10.2021.
//

import UIKit
import Cartography

class StrictCursorTextView: UITextView {

    override func closestPosition(to point: CGPoint) -> UITextPosition? {
        let beginning = self.beginningOfDocument
        let end = self.position(from: beginning, offset: self.text?.count ?? 0)
        return end
    }
}

class CanvasView: UIView {

    // MARK: - Nested Types

    typealias Design = CanvasViewDesign

    // MARK: - Subviews

    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        imageView.layer.cornerRadius = 8.0
        imageView.layer.cornerCurve = .continuous
        imageView.layer.masksToBounds = true
        return imageView
    }()
    let textView: UITextView = {
        let textView = StrictCursorTextView()
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.textAlignment = .center
        textView.isUserInteractionEnabled = false
        return textView
    }()

    // MARK: - Public Instance Properties

    let didTapCanvasViewEvent = Event<Void>()
    let textViewHeightChangedEvent = Event<Void>()

    // MARK: -

    private var lastTextViewHeight: CGFloat = 0
    private let layerShadow: CALayer.Shadow = .init(
        color: .black,
        alpha: 0.5,
        x: 0,
        y: 4,
        blur: 8,
        spread: -4
    )

    // MARK: - Initializers

    init(design: Design) {
        super.init(frame: .zero)

        setupLayout()
        applyDesign(design)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Instance Methods

    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.backgroundImageView.frame = self.bounds
            self.layer.applyShadow(self.layerShadow)

            if self.frame.height != self.lastTextViewHeight {
                self.lastTextViewHeight = self.frame.height
                self.textViewHeightChangedEvent.onNext(())
            }
        }
    }

    func setText(_ text: String) {
        textView.text = text
        textView.sizeToFit()
        textView.becomeFirstResponder()
    }

    func applyDesign(_ design: Design) {
        backgroundColor = design.backgroundColor
        backgroundImageView.image = design.backgroundImage

        textView.font = UIFontFactory.makeFont(
            from: design.fontModel,
            withSize: design.fontSize
        ) ?? .default(withSize: design.fontSize)
        textView.textColor = design.textColor
        textView.textAlignment = design.textAlignment
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        addSubview(backgroundImageView)
        backgroundImageView.frame = self.bounds

        addSubview(textView)
        constrain(self, textView) { view, textView in
            textView.center == view.center
            textView.left >= view.left + 12
            textView.right <= view.right - 12
            textView.top >= view.top + 12
            textView.bottom <= view.bottom - 12
        }

        layer.cornerRadius = 8.0
        layer.cornerCurve = .continuous
    }
}

private extension UIFont {

    static func `default`(withSize fontSize: CGFloat) -> UIFont {
        return UIFont(
            name: "Georgia-Bold",
            size: fontSize
        ) ?? UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
}

private enum Constants {

    static let maxHeight: CGFloat = 300
}
