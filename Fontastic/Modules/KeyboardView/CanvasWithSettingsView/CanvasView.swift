//
//  CanvasView.swift
//  Fontastic
//
//  Created by Timofey Surkov on 04.10.2021.
//

import UIKit
import Cartography

class CanvasView: UIView {

    struct Design {
        var backgroundColor: UIColor
        var font: UIFont
        var textColor: UIColor
        var textAlignment: NSTextAlignment
    }

    private let textView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.textAlignment = .center
        textView.isUserInteractionEnabled = false
        return textView
    }()

    private var design: Design

    private let layerShadow: CALayer.Shadow = .init(
        color: .black,
        alpha: 0.5,
        x: 0,
        y: 8,
        blur: 16,
        spread: -8
    )

    init(design: Design) {
        self.design = design

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
    }

    func setText(_ text: String) {
        textView.text = text
        textView.sizeToFit()

        textView.becomeFirstResponder()
    }

    func applyDesign(_ design: Design) {
        self.design = design

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
            textView.left == view.left + 12
            textView.right == view.right - 12
            textView.top >= view.top + 12
            textView.bottom <= view.bottom - 12
        }

        textView.delegate = self
    }
}

extension CanvasView: UITextViewDelegate {

//    func textView(
//        _ textView: UITextView,
//        shouldChangeTextIn range: NSRange,
//        replacementText text: String
//    ) -> Bool {
//        return true
//    }
}

extension CanvasView.Design {

    static let `default`: CanvasView.Design = .init(
        backgroundColor: .white,
        font: UIFont(name: "Georgia-Bold", size: 36.0) ?? UIFont.systemFont(ofSize: 36, weight: .bold),
        textColor: .black,
        textAlignment: .center
    )
}
