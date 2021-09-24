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

    struct ViewModel {

        let fontName: String
        let exampleText: String
    }

    // MARK: - Subviews

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.backgroundMain
        view.layer.cornerRadius = 12.0
        view.layer.cornerCurve = .continuous
        return view
    }()
    private let fontNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24.0, weight: .regular)
        label.textColor = Colors.textMajor
        return label
    }()
    private let exampleTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textMinor
        return label
    }()

    // MARK: - Public Properties

    override var isHighlighted: Bool {
        didSet {
            self.alpha = isHighlighted ? 0.5 : 1.0
        }
    }

    // MARK: - Private Properties

    private var viewModel: ViewModel?

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
        self.exampleTextLabel.text = viewModel.exampleText
    }

    // MARK: - Private Methods

    private func setupLayoutV1() {
        contentView.addSubview(containerView)
        containerView.addSubview(fontNameLabel)
        containerView.addSubview(exampleTextLabel)

        constrain(contentView, containerView) { contentView, containerView in
            containerView.edges == contentView.edges.inseted(by: Constants.edgeInsets)
        }

        constrain(containerView, fontNameLabel, exampleTextLabel) { container, fontName, exampleText in
            fontName.leading == container.leading + 12
            fontName.trailing == container.trailing - 12
            fontName.top == container.top + 8

            exampleText.leading == fontName.leading
            exampleText.trailing == fontName.trailing
            exampleText.top == fontName.bottom + 2
        }
    }
}

private enum Constants {

    static let edgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
}
