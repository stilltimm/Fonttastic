//
//  FontListFontTableViewCell.swift
//  Fontastic
//
//  Created by Timofey Surkov on 24.09.2021.
//

import UIKit
import Cartography

class FontListFontTableViewCell: UICollectionViewCell {

    // MARK: - Nested Types

    enum State {

        case valid(font: UIFont, text: String)
        case invalid
        case uninstalled
    }

    enum Action {

        case installFont(FontSourceModel)
        case openDetails(FontModel)
    }

    struct ViewModel {

        let fontName: String
        let state: State
        let action: Action
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
        label.font = UIFont.systemFont(ofSize: Constants.fontNameLabelTextSize, weight: .regular)
        label.textColor = Colors.textMajor
        return label
    }()
    private let fontStatusIcon = UIImageView()
    private let exampleTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textMinor
        return label
    }()

    // MARK: - Public Properties

    private(set) var viewModel: ViewModel?

    override var isHighlighted: Bool {
        didSet {
            self.alpha = isHighlighted ? 0.5 : 1.0
        }
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        selectedBackgroundView = UIView()

        setupLayoutV1()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UITableViewCell Methods

    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        self.layoutMargins = Constants.edgeInsets
    }

    // MARK: - Public Methods

    func apply(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.fontNameLabel.text = viewModel.fontName

        switch viewModel.state {
        case let .valid(font, text):
            exampleTextLabel.font = font
            exampleTextLabel.text = text

        case .invalid:
            exampleTextLabel.font = Constants.exmapleLabelDefaultFont
            exampleTextLabel.text = Constants.invalidFontDefaultText

        case .uninstalled:
            exampleTextLabel.font = Constants.exmapleLabelDefaultFont
            exampleTextLabel.text = Constants.uninstalledFontDefaultText
        }

    }

    // MARK: - Private Methods

    private func setupLayoutV1() {
        contentView.addSubview(containerView)
        containerView.addSubview(fontNameLabel)
        containerView.addSubview(fontStatusIcon)
        containerView.addSubview(exampleTextLabel)

        constrain(contentView, containerView) { contentView, containerView in
            containerView.edges == contentView.edges.inseted(by: Constants.edgeInsets)
        }

        constrain(containerView, fontNameLabel, exampleTextLabel) { container, fontName, exampleText in
            fontName.leading == container.leading + Constants.contentInsets.left
            fontName.trailing == container.trailing - Constants.contentInsets.right
            fontName.top == container.top + Constants.contentInsets.top

            exampleText.leading == fontName.leading
            exampleText.trailing == fontName.trailing
            exampleText.top == fontName.bottom + 2
        }
    }
}

extension FontListFontTableViewCell.ViewModel {

    init(withModel fontModel: FontModel, exampleText: String) {
        fontName = fontModel.name
        switch fontModel.state {
        case .invalid:
            state = .invalid
            action = .openDetails(fontModel)

        case .ready:
            if let font = UIFontFactory.makeFont(
                from: fontModel,
                withSize: Constants.exampleLabelTextSize
            ) {
                state = .valid(font: font, text: exampleText)
                action = .openDetails(fontModel)
            } else {
                state = .invalid
                action = .openDetails(fontModel)
            }

        case .uninstalled:
            state = .uninstalled
            action = .installFont(fontModel.sourceModel)
        }
    }
}

private enum Constants {

    static let edgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
    static let contentInsets = UIEdgeInsets(top: 14, left: 16, bottom: 16, right: 16)
    static let containerCornerRadius: CGFloat = 16.0

    static let fontNameLabelTextSize: CGFloat = 20.0
    static let exampleLabelTextSize: CGFloat = 14.0

    static let exmapleLabelDefaultFont: UIFont = UIFont.systemFont(
        ofSize: Constants.exampleLabelTextSize,
        weight: .regular
    )
    static let invalidFontDefaultText: String = "Font is invalid. Tap to see details"
    static let uninstalledFontDefaultText: String = "Font is not installed. Tap to see details"
}
