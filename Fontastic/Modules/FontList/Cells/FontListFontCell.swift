//
//  FontListFontCell.swift
//  Fontastic
//
//  Created by Timofey Surkov on 24.09.2021.
//

import UIKit
import Cartography
import FontasticTools

struct FontListFontViewModel {

    // MARK: - Nested Types

    enum Status {

        case valid
        case invalid
        case uninstalled

        var isInavlid: Bool {
            switch self {
            case .invalid:
                return true

            default:
                return false
            }
        }
    }

    enum Action {

        case installFont(FontSourceModel)
        case openDetails(FontModel)
    }

    // MARK: - Public Properties

    let status: Status
    let action: Action
    let fontDisplayText: String
    let fontDisplayLabelFont: UIFont
    let detailsText: String
}

extension FontListFontViewModel {

    init(withModel fontModel: FontModel) {
        fontDisplayText = Constants.fontDisplayText
        detailsText = fontModel.displayName

        switch fontModel.status {
        case .invalid:
            status = .invalid
            fontDisplayLabelFont = Constants.fontDisplayLabelDefaultFont
            action = .openDetails(fontModel)

        case .ready:
            if let font = UIFontFactory.makeFont(
                from: fontModel,
                withSize: Constants.fontDisplayLabelTextSize
            ) {
                status = .valid
                fontDisplayLabelFont = font
                action = .openDetails(fontModel)
            } else {
                status = .invalid
                fontDisplayLabelFont = Constants.fontDisplayLabelDefaultFont
                action = .openDetails(fontModel)
            }

        case .uninstalled:
            status = .uninstalled
            fontDisplayLabelFont = Constants.fontDisplayLabelDefaultFont
            action = .installFont(fontModel.sourceModel)
        }
    }
}

class FontListFontCell: UICollectionViewCell, Reusable {

    // MARK: - Static Methods

    static func height(
        for viewModel: FontListFontViewModel,
        boundingWidth: CGFloat
    ) -> CGFloat {
        let containerHeight = Constants.containerHeight

        let detailsAttributedString = NSAttributedString(
            string: viewModel.detailsText,
            attributes: [
                .font: Constants.detailsLabelFont
            ]
        )
        let detailsLabelSize = detailsAttributedString .boundingRect(
            with: CGSize(width: boundingWidth, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            context: nil
        )

        return containerHeight
            + Constants.containerToDetailsSpacing
            + ceil(detailsLabelSize.height)
    }

    // MARK: - Subviews

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.brandMainInverted
        view.layer.cornerRadius = Constants.containerCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()
    private let fontDisplayLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.clipsToBounds = false
        return label
    }()
    private let detailsTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textMinor
        label.font = Constants.detailsLabelFont
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Public Instance Properties

    private(set) var viewModel: FontListFontViewModel?

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(
                withDuration: 0.2,
                delay: 0.0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.0,
                options: .curveLinear,
                animations: {
                    self.alpha = self.isHighlighted ? 0.5 : 1.0
                    self.transform = self.isHighlighted ?
                        CGAffineTransform.init(scaleX: 0.95, y: 0.95) :
                        .identity
                }
            )
        }
    }

    // MARK: - Private Properties

    private var fontDisplayToDetailsSpacingConstraint: NSLayoutConstraint?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        selectedBackgroundView = UIView()

        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        applyShadowIfNeeded()
    }

    func apply(viewModel: FontListFontViewModel) {
        self.viewModel = viewModel

        let adjustedLineHeight = viewModel.fontDisplayLabelFont.capHeight + Constants.fontDisplayLabelSafeSpacing
        let baselineOffset = viewModel.fontDisplayLabelFont.descender + Constants.fontDisplayLabelSafeSpacing / 2

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.minimumLineHeight = adjustedLineHeight
        paragraphStyle.maximumLineHeight = adjustedLineHeight

        let attributedString = NSAttributedString(
            string: viewModel.fontDisplayText,
            attributes: [
                .font: viewModel.fontDisplayLabelFont,
                .foregroundColor: Colors.brandMain,
                .paragraphStyle: paragraphStyle,
                .baselineOffset: baselineOffset
            ]
        )
        fontDisplayLabel.attributedText = attributedString

        detailsTextLabel.text = viewModel.detailsText
    }

    func applyShadowIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.containerView.layer.applyShadow(Constants.containerShadow)
        }
    }

    // MARK: - Private Methods

    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.addSubview(fontDisplayLabel)
        contentView.addSubview(detailsTextLabel)

        constrain(
            contentView, containerView, fontDisplayLabel, detailsTextLabel
        ) { contentView, container, fontDisplay, detailsLabel in
            container.top == contentView.top
            container.left == contentView.left
            container.right == contentView.right
            (container.height == Constants.containerHeight).priority = .required

            fontDisplay.left == container.left
            fontDisplay.right == container.right
            fontDisplay.centerY == container.centerY + Constants.fontDisplayLabelCenterYOffset

            detailsLabel.left == contentView.left
            detailsLabel.right == contentView.right

            detailsLabel.top == container.bottom + Constants.containerToDetailsSpacing
        }
    }
}

private enum Constants {

    static let fontDisplayText: String = "Aa"

    static let containerHeight: CGFloat = 104.0
    static let containerCornerRadius: CGFloat = 16.0
    static let containerShadow: CALayer.Shadow = .init(
        color: .black,
        alpha: 0.5,
        x: 0,
        y: 8,
        blur: 16,
        spread: -8
    )

    static let fontDisplayLabelCenterYOffset: CGFloat = -floor(containerHeight / 20)
    static let fontDisplayLabelTextSize: CGFloat = 48.0
    static let fontDisplayLabelSafeSpacing: CGFloat = 10.0
    static let detailsLabelTextSize: CGFloat = 16.0

    static let containerToDetailsSpacing: CGFloat = 8.0

    static let fontDisplayLabelDefaultFont: UIFont = UIFont.systemFont(
        ofSize: Constants.fontDisplayLabelTextSize,
        weight: .regular
    )
    static let detailsLabelFont: UIFont = {
        if let customFont = UIFont(name: "AvenirNext", size: Constants.detailsLabelTextSize) {
            return customFont
        }
        return UIFont.systemFont(ofSize: Constants.detailsLabelTextSize, weight: .regular)
    }()
}
