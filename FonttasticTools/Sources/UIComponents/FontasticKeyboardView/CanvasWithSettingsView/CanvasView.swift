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
    let textView: UITextView = {
        let textView = StrictCursorTextView()
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.textAlignment = .center
        textView.isUserInteractionEnabled = false
        return textView
    }()
    private let watermwarkView: FonttasticWatermarkView = {
        let view = FonttasticWatermarkView()
        view.isHidden = true
        return view
    }()

    // MARK: - Public Instance Properties

    let didTapCanvasViewEvent = Event<Void>()
    let contentHeightChangedEvent = Event<Void>()

    // MARK: -

    private var lastContentHeight: CGFloat = 0
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

            if self.frame.height != self.lastContentHeight {
                self.lastContentHeight = self.frame.height
                self.contentHeightChangedEvent.onNext(())
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

    // MARK: - Private Instance Methods

    private func setupLayout() {
        addSubview(backgroundImageView)
        backgroundImageView.frame = self.bounds

        addSubview(textView)
        addSubview(watermwarkView)

        constrain(self, textView, watermwarkView) { view, textView, watermark in
            textView.center == view.center
            textView.left >= view.left + 12
            textView.right <= view.right - 12
            textView.top >= view.top + 12
            textView.bottom <= view.bottom - 12

            watermark.left == view.left + Constants.watermarkMargins
            watermark.bottom == view.bottom - Constants.watermarkMargins
        }

        layer.cornerRadius = 8.0
        layer.cornerCurve = .continuous
    }

    private func makeBlurredImage(from image: UIImage, region: CGRect, radius: Double) -> UIImage? {
        if let blurredRegionImage = image.blurImage(for: region, radius: radius) {
            return blurredRegionImage
        }
        return nil
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

    static let textViewInsets: UIEdgeInsets = UIEdgeInsets(vertical: 12, horizontal: 12)
    static let watermarkMargins: CGFloat = 4
}

extension UIImage {

    func blurImage(for rect: CGRect, radius: Double) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }

        let context = CIContext(options: nil)
        let inputImage = CIImage(cgImage: cgImage)

        guard let filter = CIFilter(name: "CIGaussianBlur") else { return nil }

        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)

        guard
            let outputImage = filter.outputImage,
            let outputCgImage = context.createCGImage(
                outputImage,
                from: CGRect(
                    origin: CGPoint(
                        x: rect.origin.x,
                        y: self.size.height - rect.maxY
                    ),
                    size: rect.size
                )
            )
        else { return nil }

        return UIImage(cgImage: outputCgImage)
    }
}
