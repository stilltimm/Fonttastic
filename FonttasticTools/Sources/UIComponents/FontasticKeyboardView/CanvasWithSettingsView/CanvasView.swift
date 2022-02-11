//
//  CanvasView.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 04.10.2021.
//

import UIKit
import Cartography

protocol CanvasTextViewDelegate: AnyObject {

    func intrinsicContentWidthForCanvasTextView() -> CGFloat?
}

class CanvasTextView: UITextView {

    weak var canvasTextViewDelegate: CanvasTextViewDelegate?

    override var intrinsicContentSize: CGSize {
        let originalSize = super.intrinsicContentSize
        let width: CGFloat
        if let overridenWidth = canvasTextViewDelegate?.intrinsicContentWidthForCanvasTextView() {
            width = overridenWidth
        } else {
            width = originalSize.width
        }
        return CGSize(width: width, height: originalSize.height)
    }

    override func closestPosition(to point: CGPoint) -> UITextPosition? {
        let beginning = self.beginningOfDocument
        let end = self.position(from: beginning, offset: self.text?.count ?? 0)
        return end
    }
}

class CanvasView: UIView, CanvasTextViewDelegate {

    // MARK: - Nested Types

    typealias Design = CanvasViewDesign

    // MARK: - Type Properties

    static let minHeight: CGFloat = 250

    // MARK: - Subviews

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        imageView.layer.cornerRadius = 8.0
        imageView.layer.cornerCurve = .continuous
        imageView.layer.masksToBounds = true
        return imageView
    }()
    let canvasTextView: CanvasTextView = {
        let textView = CanvasTextView()
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.textAlignment = .center
        textView.isUserInteractionEnabled = false

        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return textView
    }()
    private let watermwarkView: FonttasticWatermarkView = {
        let view = FonttasticWatermarkView()
        view.isHidden = true
        return view
    }()

    // MARK: - Public Instance Properties

    let didTapCanvasViewEvent = Event<Void>()
    let contentHeightChangedEvent = Event<CGFloat>()

    // MARK: - Private Instance Properties

    private var heightConstraint: NSLayoutConstraint?

    // MARK: -

    private var lastContentHeight: CGFloat = 0
    private let layerShadow: Shadow = Shadow(
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

        self.layer.applyShadow(self.layerShadow)
        canvasTextView.invalidateIntrinsicContentSize()
    }

    func setText(_ text: String) {
        canvasTextView.text = text
        canvasTextView.becomeFirstResponder()

        updateContentHeight()
    }

    func applyDesign(_ design: Design) {
        backgroundColor = design.backgroundColor
        backgroundImageView.image = design.backgroundImage

        canvasTextView.font = UIFontFactory.makeFont(
            from: design.fontModel,
            withSize: design.fontSize
        ) ?? .default(withSize: design.fontSize)
        canvasTextView.textColor = design.textColor
        canvasTextView.tintColor = design.textColor
        canvasTextView.textAlignment = design.textAlignment
    }

    func showWatermark() {
        if let backgroundImage = backgroundImageView.image {
            watermwarkView.image = makeBlurredImage(
                from: backgroundImage,
                region: watermwarkView.frame,
                radius: Constants.watermarkMargins
            )
        } else {
            watermwarkView.image = nil
        }
        watermwarkView.isHidden = false
    }

    func hideWatermark() {
        watermwarkView.isHidden = true
        watermwarkView.image = nil
    }

    func intrinsicContentWidthForCanvasTextView() -> CGFloat? {
        guard superview != nil else { return nil }
        return self.bounds.width - Constants.textViewInsets.horizontalSum
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        addSubview(backgroundImageView)
        addSubview(canvasTextView)
        addSubview(watermwarkView)

        backgroundImageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 249), for: .horizontal)
        backgroundImageView.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .horizontal)

        constrain(self, backgroundImageView, canvasTextView, watermwarkView) { view, background, textView, watermark in
            background.edges == view.edges

            textView.centerX == view.centerX
            textView.centerY == view.centerY
            self.heightConstraint = (view.height == Self.minHeight)

            watermark.left == view.left + Constants.watermarkMargins
            watermark.bottom == view.bottom - Constants.watermarkMargins
        }

        self.heightConstraint?.priority = .required

        layer.cornerRadius = 8.0
        layer.cornerCurve = .continuous

        canvasTextView.canvasTextViewDelegate = self
    }

    private func makeBlurredImage(from image: UIImage, region: CGRect, radius: Double) -> UIImage? {
        if let blurredRegionImage = image.blurImage(for: region, radius: radius) {
            return blurredRegionImage
        }
        return nil
    }

    private func updateContentHeight() {
        let contentHeight = max(self.canvasTextView.frame.height + Constants.textViewInsets.verticalSum, Self.minHeight)

        if self.lastContentHeight != contentHeight {
            self.heightConstraint?.constant = contentHeight
            setNeedsLayout()
            layoutIfNeeded()

            self.lastContentHeight = contentHeight
            DispatchQueue.main.async { [weak self] in
                self?.contentHeightChangedEvent.onNext(contentHeight)
            }
        }
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

    static let textViewInsets: UIEdgeInsets = UIEdgeInsets(vertical: 12, horizontal: 12)
    static let watermarkMargins: CGFloat = 4
}
