//
//  KeyboardLabelCell.swift
//  FontasticKeyboard
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import Cartography
import FontasticTools

class KeyboardButton: UIControl {

    // MARK: - Nested Types

    typealias Design = KeyboardButtonDesign
    typealias ViewModel = KeyboardButtonViewModelProtocol

    // MARK: - Public Instance Properties

    override var isHighlighted: Bool {
        didSet {
            guard updatesHighlightedStateFromNativeControl else { return }
            handleIsHighlightedChanged(isHighlighted)
        }
    }

    override var intrinsicContentSize: CGSize {
        let resultWidth: CGFloat
        switch design.layoutWidth {
        case let .intrinsic(spacing):
            switch viewModel.content {
            case .text:
                resultWidth = titleLabel.intrinsicContentSize.width + 2 * spacing

            case .systemIcon:
                resultWidth = design.iconSize.width + 2 * spacing
            }

        case let .fixed(width):
            resultWidth = width

        case let .flexible(flexBasis):
            resultWidth = flexBasis
        }

        return CGSize(width: resultWidth, height: design.layoutHeight)
    }

    // MARK: - Subviews

    private lazy var contentView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = design.foregroundColor
        view.layer.masksToBounds = true
        view.layer.cornerRadius = design.cornerRadius
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.textColor = .black
        label.font = design.labelFont
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        imageView.isHidden = true
        imageView.tintColor = .black
        return imageView
    }()

    // MARK: - Private Instance Properties

    private let viewModel: ViewModel
    private let design: Design
    fileprivate var updatesHighlightedStateFromNativeControl: Bool { return true }

    // MARK: - Initializers

    init(viewModel: ViewModel, design: Design) {
        self.viewModel = viewModel
        self.design = design

        super.init(frame: .zero)

        setupLayout()
        setupBusinessLogic()
        applyViewModelContent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        backgroundColor = design.backgroundColor
        layer.masksToBounds = true
        layer.cornerRadius = design.cornerRadius

        addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconImageView)

        let insets = UIEdgeInsets(top: 0, left: 0, bottom: design.shadowSize, right: 0)
        constrain(
            self, contentView, titleLabel, iconImageView
        ) { view, content, symbol, icon in
            content.edges == view.edges.inseted(by: insets)

            symbol.leading == content.leading
            symbol.trailing == content.trailing
            symbol.centerY == content.centerY + Constants.titleLabelCenterYOffset

            icon.width == self.design.iconSize.width
            icon.height == self.design.iconSize.height
            icon.center == content.center
        }
    }

    private func setupBusinessLogic() {
        self.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        self.addTarget(self, action: #selector(playClickSound), for: .touchDown)

        viewModel.shouldUpdateContentEvent.subscribe(self) { [weak self] in
            self?.applyViewModelContent()
        }
    }

    private func applyViewModelContent() {
        switch viewModel.content {
        case let .text(_, displayString):
            titleLabel.isHidden = false
            iconImageView.isHidden = true

            titleLabel.text = displayString

        case let .systemIcon(normalIconName, highlightedIconName):
            titleLabel.isHidden = true
            iconImageView.isHidden = false

            iconImageView.image = UIImage(systemName: normalIconName)
            if let highlightedIconName = highlightedIconName {
                iconImageView.highlightedImage = UIImage(systemName: highlightedIconName)
            }
        }
    }

    @objc private func handleTap() {
        viewModel.didTapEvent.onNext(viewModel.content)
    }

    @objc private func playClickSound() {
        UIDevice.current.playInputClick()
    }

    fileprivate func handleIsHighlightedChanged(_ value: Bool) {
        contentView.backgroundColor = value ?
            design.highlightedForegroundColor :
            design.foregroundColor

        iconImageView.isHighlighted = value
    }
}

class CaseChangeKeyboardButton: KeyboardButton {

    private let caseChangeViewModel: CaseChangeKeyboardButtonViewModel

    override fileprivate var updatesHighlightedStateFromNativeControl: Bool { return false }

    init(caseChangeViewModel: CaseChangeKeyboardButtonViewModel, design: Design) {
        self.caseChangeViewModel = caseChangeViewModel
        super.init(viewModel: caseChangeViewModel, design: design)

        caseChangeViewModel.didTapEvent.subscribe(self) { [weak self] _ in
            guard let self = self else { return }
            let highlighted = self.caseChangeViewModel.state.isCapitalized
            self.handleIsHighlightedChanged(highlighted)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Unimplemented")
    }
}

private enum Constants {

    static let titleLabelCenterYOffset: CGFloat = -2
}
