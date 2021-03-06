//
//  FontListFontCell.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 24.09.2021.
//

import UIKit
import Cartography

public struct FontListFontViewModel {

    // MARK: - Nested Types

    public enum Status {

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

    public enum Action {

        case installFont(FontSourceModel)
        case openDetails(FontModel)
    }

    // MARK: - Public Properties

    public let fontModel: FontModel
    public let status: Status
    public let action: Action
    public let fontDisplayText: String
    public let fontDisplayLabelFont: UIFont
    public let detailsText: String
}

extension FontListFontViewModel {

    public init(withModel fontModel: FontModel) {
        self.fontModel = fontModel
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

    public static func height(
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

    private let containerShadowView: ShadowView = ShadowView(
        cornerRadius: Constants.containerCornerRadius,
        shadowSpread: -8,
        shadowRadius: 16,
        shadowOffset: CGSize(width: 0, height: 7),
        shadowOpacity: 0.5,
        shadowColor: .black
    )
    private let linearGradientView: UIView = {
        let view = LinearGradientView(linearGradient: Constants.backgroundLinearGradient)
        view.layer.cornerRadius = Constants.containerCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()
    private let fontDisplayLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    private let detailsTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.blackAndWhite
        label.font = Constants.detailsLabelFont
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Public Instance Properties

    public private(set) var viewModel: FontListFontViewModel?

    public override var isHighlighted: Bool {
        didSet {
            UIView.animate(withConfig: .fastControl) {
                self.transform = self.isHighlighted ?
                    CGAffineTransform.init(scaleX: 0.95, y: 0.95) :
                    .identity
            }
        }
    }

    // MARK: - Private Properties

    private var fontDisplayToDetailsSpacingConstraint: NSLayoutConstraint?

    // MARK: - Initializers

    public override init(frame: CGRect) {
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

    public func apply(viewModel: FontListFontViewModel) {
        self.viewModel = viewModel

        let baselineOffset = viewModel.fontDisplayLabelFont.descender
            + (Constants.containerHeight / 5)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.minimumLineHeight = Constants.containerHeight
        paragraphStyle.maximumLineHeight = Constants.containerHeight

        let attributedString = NSAttributedString(
            string: viewModel.fontDisplayText,
            attributes: [
                .font: viewModel.fontDisplayLabelFont,
                .foregroundColor: Colors.blackAndWhite,
                .paragraphStyle: paragraphStyle,
                .baselineOffset: baselineOffset
            ]
        )
        fontDisplayLabel.attributedText = attributedString

        detailsTextLabel.text = viewModel.detailsText
    }

    // MARK: - Private Methods

    private func setupLayout() {
        contentView.addSubview(containerShadowView)
        containerShadowView.contentView.addSubview(linearGradientView)
        containerShadowView.contentView.addSubview(fontDisplayLabel)
        contentView.addSubview(detailsTextLabel)

        constrain(
            contentView, containerShadowView, linearGradientView, fontDisplayLabel, detailsTextLabel
        ) { contentView, container, linearGradient, fontDisplay, detailsLabel in
            container.top == contentView.top
            container.left == contentView.left
            container.right == contentView.right
            (container.height == Constants.containerHeight).priority = .required

            linearGradient.edges == container.edges

            fontDisplay.left == container.left
            fontDisplay.right == container.right
            fontDisplay.centerY == container.centerY

            detailsLabel.left == contentView.left
            detailsLabel.right == contentView.right

            detailsLabel.top == container.bottom + Constants.containerToDetailsSpacing
        }
    }
}

private enum Constants {

    static let fontDisplayText: String = "Ab"

    static let containerHeight: CGFloat = 104.0
    static let containerCornerRadius: CGFloat = 16.0
    static let containerShadow: Shadow = Shadow(
        color: .black,
        alpha: 0.5,
        x: 0,
        y: 8,
        blur: 16,
        spread: -8
    )

    static let fontDisplayLabelTextSize: CGFloat = 48.0
    static let fontDisplayLabelSafeSpacing: CGFloat = 10.0
    static let detailsLabelTextSize: CGFloat = 16.0

    static let containerToDetailsSpacing: CGFloat = 8.0

    static let fontDisplayLabelDefaultFont: UIFont = UIFont.systemFont(
        ofSize: Constants.fontDisplayLabelTextSize,
        weight: .regular
    )
    static let detailsLabelFont: UIFont = {
        if let customFont = UIFont(name: "AvenirNext-Medium", size: Constants.detailsLabelTextSize) {
            return customFont
        }
        return UIFont.systemFont(ofSize: Constants.detailsLabelTextSize, weight: .regular)
    }()

    static let backgroundLinearGradient: LinearGradient = LinearGradient(
        direction: CGPoint(x: 0, y: 1),
        locations: [0, 1],
        colors: [Colors.glassBackgroundTop, Colors.glassBackgroundBottom]
    )
}
