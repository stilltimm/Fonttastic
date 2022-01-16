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
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
        return view
    }()
    private let watermarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = FonttasticToolsAsset.watermark.image
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let watermarkLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = Constants.watermarkLabelText
        label.textColor = UIColor.white
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
        self.layer.cornerRadius = 8

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
    static let watermarkLabelText: String = "Fonttastic"

    static let edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 6)
    static let iconToLabelSpacing: CGFloat = 4
    static let iconSize: CGSize = CGSize(width: 20, height: 20)
}
