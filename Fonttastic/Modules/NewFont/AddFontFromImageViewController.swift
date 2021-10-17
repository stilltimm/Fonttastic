//
//  AddFontFromImageViewController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit
import Cartography
import SVGKit

class AddFontFromImageViewController: UIViewController {

    // MARK: - Nested Types

    // MARK: - Subviews

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.backgroundColor = .clear
        scrollView.canCancelContentTouches = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private let sourceImageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 24.0)
        label.textColor = Colors.titleMinor
        label.numberOfLines = 0
        label.text = "Source image"
        return label
    }()
    private let sourceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    private let resultImagesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 24.0)
        label.textColor = Colors.titleMinor
        label.numberOfLines = 0
        label.text = "Letters vector images"
        return label
    }()
    private var activityIndicator = UIActivityIndicatorView()
    private var svgImageViews: [SVGKFastImageView] = []
    private let letterWidthSlider: UISlider = {
        let slider = UISlider()
        slider.value = 1.0
        return slider
    }()

    // MARK: - Private Properties

    private let imageProcessingService: ImageProcessingService = DefaultImageProcessingService.shared

    private let sourceImage: UIImage
    private var svgAlphabetModel: SVGAlphabetSourceModel?

    private let minLetterImageWidth: CGFloat = 64.0
    private let maxLetterImageWidth: CGFloat = UIScreen.main.portraitWidth - Constants.contentInsets.horizontalSum
    private lazy var currencyImageWidth: CGFloat = maxLetterImageWidth

    private var firstLetterViewWidthConstraint: NSLayoutConstraint?

    // MARK: - Initializers

    init(sourceImage: UIImage) {
        self.sourceImage = sourceImage

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.backgroundMain
        navigationItem.title = Constants.title
        navigationItem.largeTitleDisplayMode = .never

        setupLayout()
        setupBusinsessLogic()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        sourceImageView.layer.applyShadow(
            color: .black,
            alpha: 1,
            x: 0,
            y: 8,
            blur: 16,
            spread: -8
        )
    }

    // MARK: - Layout Setup

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(sourceImageLabel)
        containerView.addSubview(sourceImageView)
        containerView.addSubview(resultImagesLabel)
        containerView.addSubview(activityIndicator)

        let imageHeightToWidthRatio = sourceImage.size.height / sourceImage.size.width
        constrain(
            view, scrollView, containerView, sourceImageLabel, sourceImageView, resultImagesLabel, activityIndicator
        ) { view, scrollView, containerView, sourceImageLabel, sourceImageView, resultImagesLabel, activityIndicator in
            scrollView.edges == view.edges
            containerView.width == view.width
            containerView.height >= view.height

            sourceImageLabel.left == containerView.left + Constants.contentInsets.left
            sourceImageLabel.right == containerView.right - Constants.contentInsets.right
            sourceImageLabel.top == containerView.top + Constants.contentInsets.top

            sourceImageView.left == sourceImageLabel.left
            sourceImageView.right == sourceImageLabel.right
            sourceImageView.top == sourceImageLabel.bottom + Constants.contentSpacing
            sourceImageView.height == sourceImageView.width * imageHeightToWidthRatio

            resultImagesLabel.left == sourceImageLabel.left
            resultImagesLabel.right == sourceImageLabel.right
            resultImagesLabel.top == sourceImageView.bottom + Constants.contentSpacing

            activityIndicator.top == resultImagesLabel.bottom + Constants.contentSpacing
            activityIndicator.centerX == containerView.centerX

            containerView.bottom >= activityIndicator.bottom + Constants.contentInsets.bottom
        }

        view.addSubview(letterWidthSlider)
        constrain(view, letterWidthSlider) { view, slider in
            slider.bottom == view.safeAreaLayoutGuide.bottom - Constants.contentInsets.bottom
            slider.left == view.safeAreaLayoutGuide.left + Constants.contentInsets.left
            slider.right == view.safeAreaLayoutGuide.right - Constants.contentInsets.left
        }

        sourceImageView.layer.cornerRadius = 16
        sourceImageView.layer.cornerCurve = .continuous
        sourceImageView.layer.masksToBounds = true
        sourceImageView.image = sourceImage

        activityIndicator.startAnimating()

        letterWidthSlider.isHidden = true
    }

    private func setupSVGLetterImageViewsLayout(from svgAlphabetSource: SVGAlphabetSourceModel) {
        svgImageViews.forEach { $0.removeFromSuperview() }
        svgImageViews.removeAll()

        for (i, svgLetterSource) in svgAlphabetSource.letterSources.enumerated() {
            let letter = svgLetterSource.letter
            let svgContents = svgLetterSource.svgContents
            guard let svgData = svgContents.data(using: .utf8) else {
                print("Failed to create SVG data for letter \"\(letter)\" from string \(svgContents)")
                continue
            }

            let svgImage = SVGKImage(data: svgData)
            guard let imageView = SVGKFastImageView(svgkImage: svgImage) else {
                print("Failed to create SVGKFastImageView for letter \"\(letter)\"")
                continue
            }

            containerView.addSubview(imageView)

            if i == 0 {
                constrain(resultImagesLabel, imageView) { resultImagesLabel, imageView in
                    imageView.top == resultImagesLabel.bottom + Constants.contentSpacing
                    firstLetterViewWidthConstraint = (imageView.width == currencyImageWidth)
                }
            }
            if let previousImageView = svgImageViews[safe: i - 1] {
                constrain(previousImageView, imageView) { previousImageView, imageView in
                    imageView.top == previousImageView.bottom + Constants.contentSpacing
                    imageView.width == previousImageView.width
                }
            }
            if i == svgAlphabetSource.letterSources.count - 1 {
                constrain(containerView, imageView) { containerView, imageView in
                    containerView.bottom >= imageView.bottom + Constants.contentSpacing
                }
            }

            constrain(imageView, sourceImageLabel) { imageView, sourceImageLabel in
                imageView.left == sourceImageLabel.left
                imageView.height == imageView.width
            }

            svgImageViews.append(imageView)
        }

        DispatchQueue.main.async { [weak self] in
            self?.updateScrollViewContentSize()
        }
    }

    private func updateScrollViewContentSize() {
        let contentRect = scrollView.subviews.reduce(into: CGRect.zero) { partialResult, subview in
            partialResult = partialResult.union(subview.frame)
        }
        scrollView.contentSize = contentRect.size
    }

    // MARK: - Business Logic

    private func setupBusinsessLogic() {
        tryToResolveAlphabetType()

        letterWidthSlider.addTarget(self, action: #selector(handleSliderValueDidChange), for: .valueChanged)
    }

    // MARK: - Slider Logic

    @objc private func handleSliderValueDidChange() {
        let expectedLetterWidth = ceil(letterwWidth(for: CGFloat(letterWidthSlider.value)))
        if
            let widthConstraint = firstLetterViewWidthConstraint,
            widthConstraint.constant != expectedLetterWidth
        {
            widthConstraint.constant = expectedLetterWidth

            DispatchQueue.main.async { [weak self] in
                self?.updateScrollViewContentSize()
            }
        }
    }

    // MARK: - Image Parsing Flow

    private func tryToResolveAlphabetType() {
        imageProcessingService.resolveAlphabetType(from: sourceImage) { [weak self] result in
            switch result {
            case let .failure(error):
                print("Failed to resolveAlphabetType, error: \(error.localizedDescription)")

            case let .success(alphabetType):
                print("Succesffully resolved alphabet type: \(alphabetType)")
                self?.tryToMakeAlphabetSource(with: alphabetType)
            }
        }
    }

    private func tryToMakeAlphabetSource(with alphabetType: AlphabetType) {
        imageProcessingService.makeBitmapAlphabetSource(from: sourceImage, for: alphabetType) { [weak self] result in
            switch result {
            case let .failure(error):
                print("Failed to make bitmap alphabet source, error: \(error.localizedDescription)")

            case let .success(alphabetSourceModel):
                print("Succesffully made bitmap alphabet source model")
                self?.tryToMakeSVGs(from: alphabetSourceModel)
            }
        }
    }

    private func tryToMakeSVGs(from bitmapAlphabetSourceModel: BitmapAlphabetSourceModel) {
        imageProcessingService.makeSVGAlphabetSource(from: bitmapAlphabetSourceModel) { [weak self] result in
            switch result {
            case let .failure(error):
                print("Failed make SVG alphabet source, error: \(error.localizedDescription)")

            case let .success(alphabetSourceModel):
                print("Succesffully made SVG alphabet source model")
                self?.processSVGAlphabetSource(alphabetSourceModel)
            }
        }
    }

    private func processSVGAlphabetSource(_ svgAlphabetSourceModel: SVGAlphabetSourceModel) {
        self.svgAlphabetModel = svgAlphabetSourceModel

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }

            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.letterWidthSlider.isHidden = false
            self.setupSVGLetterImageViewsLayout(from: svgAlphabetSourceModel)
        }
    }

    // MARK: - Utils

    private func letterwWidth(for sliderValue: CGFloat) -> CGFloat {
        let clippedSliderValue = min(max(sliderValue, 0.0), 1.0)
        return minLetterImageWidth + clippedSliderValue * (maxLetterImageWidth - minLetterImageWidth)
    }

    private func imageFromBezierPath(path: UIBezierPath, size: CGSize) -> UIImage {
        var image = UIImage()
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState()
            path.fill()
            image = UIGraphicsGetImageFromCurrentImageContext()!
            context.restoreGState()
            UIGraphicsEndImageContext()
        }

        return image
    }
}

private enum Constants {

    static let title = "Add font from image"

    static let contentInsets: UIEdgeInsets = .init(vertical: 16, horizontal: 16)
    static let contentSpacing: CGFloat = 16
}
