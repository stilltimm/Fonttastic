//
//  PaywallItemView.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 21.11.2021.
//

import UIKit
import Cartography
import FonttasticTools

class PaywallItemView: UIControl {

    // MARK: - Internal Instance Properties

    let model: PaywallItem

    let didSelectEvent = FonttasticTools.Event<Void>()

    override var isSelected: Bool {
        didSet {
            updateSelectedState()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withConfig: .fastControl) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            }
        }
    }

    // MARK: - Subviews

    private let containerView: ShadowView = {
         let shadowView =  ShadowView(
            cornerRadius: 16,
            shadow: Shadow(
                color: .black,
                alpha: 0.5,
                x: 0,
                y: 7,
                blur: 16,
                spread: -8
            )
        )
        shadowView.isUserInteractionEnabled = false
        return shadowView
    }()
    private let linearGradientView: UIView = {
        let view = LinearGradientView(linearGradient: .glass)
        view.isUserInteractionEnabled = false
        return view
    }()
    private let checkboxContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.brandMainLight.withAlphaComponent(0.3)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = Constants.checkboxSize.height / 2
        view.layer.cornerCurve = .circular
        view.isUserInteractionEnabled = false
        return view
    }()
    private let checkboxImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.white
        imageView.alpha = 0.0
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20)
        label.textColor = Colors.blackAndWhite
        label.isUserInteractionEnabled = false
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        label.textColor = Colors.blackAndWhite.withAlphaComponent(0.8)
        label.isUserInteractionEnabled = false
        return label
    }()
    private lazy var strikethroughPriceLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        return label
    }()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        label.textColor = Colors.blackAndWhite
        label.isUserInteractionEnabled = false
        return label
    }()

    // MARK: - Initializers

    init(model: PaywallItem) {
        self.model = model

        super.init(frame: .zero)

        setupLayout()
        setupTapHandling()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Instance Methods

    // swiftlint:disable:next function_body_length
    private func setupLayout() {
        self.containerView.contentView.layer.borderColor = Colors.brandMainLight.cgColor
        self.containerView.contentView.layer.borderWidth = 0
        self.backgroundColor = .clear

        addSubview(containerView)
        containerView.contentView.addSubview(linearGradientView)
        containerView.contentView.addSubview(checkboxContainerView)
        checkboxContainerView.addSubview(checkboxImageView)
        containerView.contentView.addSubview(titleLabel)
        containerView.contentView.addSubview(subtitleLabel)
        containerView.contentView.addSubview(priceLabel)

        titleLabel.setContentCompressionResistancePriority(
            UILayoutPriority(rawValue: 249),
            for: .horizontal
        )
        titleLabel.setContentHuggingPriority(
            UILayoutPriority(rawValue: 249),
            for: .horizontal
        )
        subtitleLabel.setContentCompressionResistancePriority(
            UILayoutPriority(rawValue: 249),
            for: .horizontal
        )
        subtitleLabel.setContentHuggingPriority(
            UILayoutPriority(rawValue: 249),
            for: .horizontal
        )

        constrain(
            self,
            containerView,
            linearGradientView,
            checkboxContainerView,
            checkboxImageView,
            titleLabel,
            subtitleLabel,
            priceLabel
        ) { view, container, linearGradient, checkboxContainer, checkboxImage, title, subtitle, price in
            container.edges == view.edges
            linearGradient.edges == container.edges

            checkboxContainer.width == Constants.checkboxSize.width
            checkboxContainer.height == Constants.checkboxSize.height
            checkboxContainer.centerY == container.centerY
            checkboxContainer.left == container.left + Constants.edgeInsets.left

            checkboxImage.edges == checkboxContainer.edges.inseted(by: 4)

            title.left == checkboxContainer.right + Constants.checkboxToTitleSpacing
            title.top == container.top + Constants.edgeInsets.top

            subtitle.left == title.left
            subtitle.right == title.right

            price.right == container.right - Constants.edgeInsets.right
            price.centerY == container.centerY
        }

        titleLabel.text = model.title
        priceLabel.text = model.price

        if let strikethroughPrice = model.strikethroughPrice {
            addSubview(strikethroughPriceLabel)
            strikethroughPriceLabel.attributedText = NSAttributedString(
                string: strikethroughPrice,
                attributes: [
                    .font: UIFont(name: "AvenirNext-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16),
                    .foregroundColor: Colors.blackAndWhite.withAlphaComponent(0.3),
                    .strikethroughStyle: 1,
                    .strikethroughColor: Colors.blackAndWhite
                ]
            )
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

        if let subtitle = model.subtitle {
            subtitleLabel.text = subtitle
            constrain(self, titleLabel, subtitleLabel) { view, title, subtitle in
                subtitle.top == title.bottom + Constants.titleToSubtitleSpacing
                subtitle.bottom == view.bottom - Constants.edgeInsets.bottom
            }
        } else {
            constrain(self, titleLabel) { view, title in
                title.bottom == view.bottom - Constants.edgeInsets.bottom
            }
        }
    }

    private func setupTapHandling() {
        self.addTarget(self, action: #selector(self.handleTapEvent), for: .touchUpInside)
    }

    @objc private func handleTapEvent() {
        didSelectEvent.onNext(())
    }

    private func updateSelectedState() {
        UIView.animate(withConfig: .fastControl) {
            self.containerView.contentView.layer.borderWidth = self.isSelected ? 2.0 : 0.0
            self.checkboxContainerView.backgroundColor = self.isSelected ?
                Colors.brandMainLight :
                Colors.brandMainLight.withAlphaComponent(0.3)
            self.checkboxImageView.alpha = self.isSelected ? 1.0 : 0.0
        }
    }
}

private extension LinearGradient {

    static let glass = LinearGradient(
        direction: CGPoint(x: 0, y: 1),
        locations: [0, 1],
        colors: [Colors.glassBackgroundTop, Colors.glassBackgroundBottom]
    )
}

private enum Constants {

    static let edgeInsets: UIEdgeInsets = UIEdgeInsets(vertical: 14, horizontal: 20)
    static let checkboxSize: CGSize = CGSize(width: 22, height: 22)
    static let checkboxToTitleSpacing: CGFloat = 16
    static let titleRightSpacing: CGFloat = 8
    static let titleToSubtitleSpacing: CGFloat = 2
    static let strikethroughtPriceToPriceSpacing: CGFloat = 8
}
