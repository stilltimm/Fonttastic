//
//  CanvasView.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 04.10.2021.
//

import UIKit
import Cartography
import FonttasticTools

class StrictCursorTextView: UITextView {

    override func closestPosition(to point: CGPoint) -> UITextPosition? {
        let beginning = self.beginningOfDocument
        let end = self.position(from: beginning, offset: self.text?.count ?? 0)
        return end
    }
}

class CanvasView: UIView {

    // MARK: - Nested Types

    struct Design {
        var backgroundColor: UIColor
        var font: UIFont
        var textColor: UIColor
        var textAlignment: NSTextAlignment
    }

    // MARK: - Subviews

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
        y: 8,
        blur: 16,
        spread: -8
    )

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Instance Methods

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.applyShadow(layerShadow)

        DispatchQueue.main.async { [weak self] in
            guard
                let self = self,
                self.frame.height != self.lastTextViewHeight
            else { return }

            self.lastTextViewHeight = self.frame.height
            self.textViewHeightChangedEvent.onNext(())
        }
    }

    func setText(_ text: String) {
        textView.text = text
        textView.sizeToFit()
        textView.becomeFirstResponder()
    }

    func applyDesign(_ design: Design) {
        backgroundColor = design.backgroundColor

        textView.font = design.font
        textView.textColor = design.textColor
        textView.textAlignment = design.textAlignment
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        layer.cornerRadius = 8.0
        layer.cornerCurve = .continuous

        addSubview(textView)
        constrain(self, textView) { view, textView in
            textView.center == view.center
            textView.left >= view.left + 12
            textView.right <= view.right - 12
            textView.top >= view.top + 12
            textView.bottom <= view.bottom - 12
        }
    }
}

extension CanvasView.Design {

    static let `default`: CanvasView.Design = .init(
        backgroundColor: .white,
        font: UIFont(name: "Georgia-Bold", size: 36.0) ?? UIFont.systemFont(ofSize: 36, weight: .bold),
        textColor: .black,
        textAlignment: .center
    )
}

private enum Constants {

    static let maxHeight: CGFloat = 300
}
