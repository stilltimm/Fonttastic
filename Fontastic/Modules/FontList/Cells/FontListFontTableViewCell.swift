//
//  FontListFontTableViewCell.swift
//  Fontastic
//
//  Created by Timofey Surkov on 24.09.2021.
//

import UIKit
import Cartography

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
    let fontNameText: String
    let fontNameLabelFont: UIFont
    let detailsText: String?
}

extension FontListFontViewModel {

    init(withModel fontModel: FontModel) {
        fontNameText = "Aa"
        detailsText = fontModel.displayName

        switch fontModel.status {
        case .invalid:
            status = .invalid
            fontNameLabelFont = Constants.fontNameLabelDefaultFont
            action = .openDetails(fontModel)

        case .ready:
            if let font = UIFontFactory.makeFont(
                from: fontModel,
                withSize: Constants.fontNameLabelTextSize
            ) {
                status = .valid
                fontNameLabelFont = font
                action = .openDetails(fontModel)
            } else {
                status = .invalid
                fontNameLabelFont = Constants.fontNameLabelDefaultFont
                action = .openDetails(fontModel)
            }

        case .uninstalled:
            status = .uninstalled
            fontNameLabelFont = Constants.fontNameLabelDefaultFont
            action = .installFont(fontModel.sourceModel)
        }
    }
}

class FontListFontTableViewCell: UICollectionViewCell {

    // MARK: - Static Methods

    static func height(
        for viewModel: FontListFontViewModel,
        boundingWidth: CGFloat
    ) -> CGFloat {
        let contentBoundingWidth = boundingWidth
            - Constants.contentInsets.horizontalSum

        let textBoundingWidth = contentBoundingWidth
            - Constants.statusIconSize.width
            - Constants.fontNameToStatusIconSpacing
        let textBoundingSize = CGSize(width: textBoundingWidth, height: .greatestFiniteMagnitude)
        let fontNameAttributedString = NSAttributedString(
            string: viewModel.fontNameText,
            attributes: [
                .font: viewModel.fontNameLabelFont
            ]
        )
        let fontNameLabelSize = fontNameAttributedString.boundingRect(
            with: textBoundingSize,
            options: .usesLineFragmentOrigin,
            context: nil
        )
        let fontNameLabelHeight = ceil(fontNameLabelSize.height)
        let fontNameAndStatusHeight = max(fontNameLabelHeight, Constants.statusIconSize.height)

        let contentHeight: CGFloat
        if let detailsText = viewModel.detailsText {
            let detailsAttributedString = NSAttributedString(
                string: detailsText,
                attributes: [
                    .font: Constants.detailsLabelFont
                ]
            )
            let detailsTextSize = detailsAttributedString.boundingRect(
                with: textBoundingSize,
                options: .usesLineFragmentOrigin,
                context: nil
            )
            let detailsTextHeight = ceil(detailsTextSize.height)
            contentHeight = fontNameAndStatusHeight
                + Constants.fontNameToDetailsSpacing
                + detailsTextHeight
        } else {
            contentHeight = fontNameAndStatusHeight
        }

        return contentHeight
            + Constants.contentInsets.verticalSum
    }

    // MARK: - Subviews

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.backgroundMain
        view.layer.cornerRadius = Constants.containerCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()
    private let fontNameLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.fontNameLabelDefaultFont
        label.textColor = Colors.textMajor
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    private let fontStatusView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.statusIconSize.height / 2
        view.layer.masksToBounds = true
        return view
    }()
    private let detailsTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textMinor
        label.font = Constants.detailsLabelFont
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Public Properties

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

    private var fontNameToDetailsSpacingConstraint: NSLayoutConstraint?

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

    func apply(viewModel: FontListFontViewModel) {
        self.viewModel = viewModel

        fontNameLabel.text = viewModel.fontNameText
        fontNameLabel.font = viewModel.fontNameLabelFont

        if let detailsText = viewModel.detailsText {
            detailsTextLabel.text = detailsText
            detailsTextLabel.isHidden = false
            fontNameToDetailsSpacingConstraint?.constant = Constants.fontNameToDetailsSpacing
        } else {
            detailsTextLabel.text = ""
            detailsTextLabel.isHidden = true
            fontNameToDetailsSpacingConstraint?.constant = 0
        }

        fontNameLabel.alpha = viewModel.status.isInavlid ? 0.7 : 1.0

        switch viewModel.status {
        case .invalid:
            fontStatusView.backgroundColor = UIColor.systemRed

        case .uninstalled:
            fontStatusView.backgroundColor = UIColor.systemBlue

        case .valid:
            fontStatusView.backgroundColor = UIColor.systemGreen
        }
    }

    // MARK: - Private Methods

    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.addSubview(fontNameLabel)
        containerView.addSubview(fontStatusView)
        containerView.addSubview(detailsTextLabel)

        constrain(contentView, containerView) { contentView, containerView in
            containerView.edges == contentView.edges
        }

        constrain(
            containerView, fontNameLabel, fontStatusView, detailsTextLabel
        ) { container, fontName, statusIcon, detailsText in
            statusIcon.width == Constants.statusIconSize.width
            statusIcon.height == Constants.statusIconSize.height
            statusIcon.trailing == container.trailing - Constants.contentInsets.right
            statusIcon.centerY == container.centerY

            fontName.leading == container.leading + Constants.contentInsets.left
            fontName.trailing == statusIcon.leading - Constants.fontNameToStatusIconSpacing
            fontName.top == container.top + Constants.contentInsets.top

            detailsText.leading == fontName.leading
            detailsText.trailing == fontName.trailing
            fontNameToDetailsSpacingConstraint =
                detailsText.top == fontName.bottom + Constants.fontNameToDetailsSpacing
            detailsText.bottom == container.bottom - Constants.contentInsets.bottom
        }
    }
}

private enum Constants {

    static let contentInsets = UIEdgeInsets(top: 14, left: 16, bottom: 16, right: 16)
    static let containerCornerRadius: CGFloat = 16.0

    static let fontNameLabelTextSize: CGFloat = 48.0
    static let detailsLabelTextSize: CGFloat = 16.0
    static let fontNameToDetailsSpacing: CGFloat = 2.0

    static let statusIconSize: CGSize = .init(width: 12, height: 12)
    static let fontNameToStatusIconSpacing: CGFloat = 8

    static let fontNameLabelDefaultFont: UIFont = UIFont.systemFont(
        ofSize: Constants.fontNameLabelTextSize,
        weight: .regular
    )
    static let detailsLabelFont: UIFont = UIFont.systemFont(
        ofSize: Constants.detailsLabelTextSize,
        weight: .regular
    )

    static let invalidFontDetailsText: String = "There is some problem with this font. Tap to see details"
    static let uninstalledFontDetailsText: String = "Font is not installed. Tap to install it"
}
