//
//  FonttasticWatermarkView.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 19.11.2021.
//

import UIKit
import Cartography

class FonttasticWatermarkView: UIImageView {

    // MARK: - Subviews

    private let backgroundOverlayImageView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        return view
    }()
    private let watermarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(
            named: Constants.watermarkIconName,
            in: Bundle(for: FonttasticWatermarkView.self),
            compatibleWith: nil
        )
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let watermarkLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir Next", size: 12) ?? UIFont.systemFont(ofSize: 12)
        label.text = Constants.watermarkLabelText
        label.textColor = UIColor(white: 0.0, alpha: 0.2)
        return label
    }()

    // MARK: - Internal Instance Properties

    override var intrinsicContentSize: CGSize {
        let width = Constants.edgeInsets.horizontalSum
            + Constants.iconToLabelSpacing
            + Constants.iconSize.width
            + watermarkLabel.intrinsicContentSize.width
        return CGSize(
            width: width,
            height: Constants.iconSize.height + Constants.edgeInsets.verticalSum
        )
    }

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        self.contentMode = .center
        self.layer.masksToBounds = true
        self.layer.cornerCurve = .continuous
        self.layer.cornerRadius = 6

        addSubview(backgroundOverlayImageView)
        addSubview(watermarkImageView)
        addSubview(watermarkLabel)

        constrain(
            self, backgroundOverlayImageView, watermarkImageView, watermarkLabel
        ) { view, backgroundOverlay, imageView, label in
            backgroundOverlay.edges == view.edges

            imageView.width == Constants.iconSize.width
            imageView.height == Constants.iconSize.height
            imageView.left == view.left + Constants.edgeInsets.left
            imageView.top == view.top + Constants.edgeInsets.top
            imageView.bottom == view.bottom - Constants.edgeInsets.bottom

            label.centerY == view.centerY
            label.left == imageView.right + Constants.iconToLabelSpacing
            label.right == view.right - Constants.edgeInsets.right
        }
    }
}

private enum Constants {

    static let watermarkIconName: String = "fonttastic-watermark-icon"
    static let watermarkLabelText: String = "Made with Fonttastic"

    static let edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 4)
    static let iconToLabelSpacing: CGFloat = 4
    static let iconSize: CGSize = CGSize(width: 20, height: 20)
}
