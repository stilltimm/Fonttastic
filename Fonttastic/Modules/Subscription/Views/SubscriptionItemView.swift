//
//  SubscriptionItemView.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 21.11.2021.
//

import UIKit
import Cartography
import FonttasticTools

class SubscriptionItemView: UIControl {

    // MARK: - Internal Instance Properties

    let didSelectEvent = FonttasticTools.Event<Void>()

    override var isSelected: Bool {
        didSet {
            updateSelectedState()
        }
    }

    // MARK: - Subviews

    private let checkboxContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.backgroundFocused
        view.layer.masksToBounds = true
        view.layer.cornerRadius = Constants.checkboxSize.height / 2
        view.layer.cornerCurve = .circular
        return view
    }()
    private let checkboxImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.white
        imageView.alpha = 0.0
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = Colors.textMajor
        return label
    }()
    private lazy var strikethroughPriceLabel = UILabel()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext", size: 16) ?? UIFont.systemFont(ofSize: 16)
        label.textColor = Colors.textMajor
        return label
    }()

    // MARK: - Private Instance Properties

    private let model: SubscriptionItemModel

    private let priceFormatter = PriceFormatter()

    // MARK: - Initializers

    init(model: SubscriptionItemModel) {
        self.model = model

        super.init(frame: .zero)

        setupLayout()
        setupTapHandling()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        self.layer.borderColor = Colors.brandMainLight.cgColor
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 16
        self.layer.cornerCurve = .continuous
        self.backgroundColor = Colors.backgroundMinor

        addSubview(checkboxContainerView)
        checkboxContainerView.addSubview(checkboxImageView)
        addSubview(titleLabel)
        addSubview(priceLabel)

        if model.strikethroughPrice != nil {
            addSubview(strikethroughPriceLabel)
            constrain(self, titleLabel, strikethroughPriceLabel, priceLabel) { view, title, strikethroughPrice, price in
                strikethroughPrice.left == title.right + Constants.titleRightSpacing
                strikethroughPrice.centerY == view.centerY
                price.left == strikethroughPrice.right + Constants.strikethroughtPriceToPriceSpacing
            }
        } else {
            constrain(titleLabel, priceLabel) { title, price in
                price.left == title.right + Constants.titleRightSpacing
            }
        }

        titleLabel.setContentCompressionResistancePriority(
            UILayoutPriority(rawValue: 249),
            for: .horizontal
        )
        titleLabel.setContentHuggingPriority(
            UILayoutPriority(rawValue: 249),
            for: .horizontal
        )

        constrain(
            self, checkboxContainerView, checkboxImageView, titleLabel, priceLabel
        ) { view, checkboxContainer, checkboxImage, title, price in
            checkboxContainer.width == Constants.checkboxSize.width
            checkboxContainer.height == Constants.checkboxSize.height
            checkboxContainer.centerY == view.centerY
            checkboxContainer.left == view.left + Constants.edgeInsets.left

            checkboxImage.edges == checkboxContainer.edges.inseted(by: 4)

            title.left == checkboxContainer.right + Constants.checkboxToTitleSpacing
            title.top == view.top + Constants.edgeInsets.top
            title.bottom == view.bottom - Constants.edgeInsets.bottom

            price.right == view.right - Constants.edgeInsets.right
            price.centerY == view.centerY
        }

        titleLabel.text = model.title
        if let strikethroughPrice = model.strikethroughPrice {
            strikethroughPriceLabel.attributedText = NSAttributedString(
                string: priceFormatter.string(from: strikethroughPrice),
                attributes: [
                    .font: UIFont(name: "AvenirNext", size: 16) ?? UIFont.systemFont(ofSize: 16),
                    .foregroundColor: Colors.textMinor,
                    .strikethroughStyle: 1,
                    .strikethroughColor: Colors.textMinor
                ]
            )
        }
        priceLabel.text = priceFormatter.string(from: model.price)
    }

    private func setupTapHandling() {
        self.addTarget(self, action: #selector(self.handleTapEvent), for: .touchUpInside)
    }

    @objc private func handleTapEvent() {
        didSelectEvent.onNext(())
    }

    private func updateSelectedState() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseOut
        ) {
            self.layer.borderWidth = self.isSelected ? 3.0 : 0.0
            self.checkboxContainerView.backgroundColor = self.isSelected ?
                Colors.brandMainLight :
                Colors.backgroundMinor
            self.checkboxImageView.alpha = self.isSelected ? 1.0 : 0.0
        }
    }
}

private enum Constants {

    static let edgeInsets: UIEdgeInsets = UIEdgeInsets(vertical: 14, horizontal: 20)
    static let checkboxSize: CGSize = CGSize(width: 22, height: 22)
    static let checkboxToTitleSpacing: CGFloat = 16
    static let titleRightSpacing: CGFloat = 8
    static let strikethroughtPriceToPriceSpacing: CGFloat = 8
}
