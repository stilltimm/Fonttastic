//
//  KeyboardLabelCell.swift
//  FontasticKeyboard
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import Cartography
import FonttasticTools
import AudioToolbox

class KeyboardButton: UIControl {

    // MARK: - Nested Types

    typealias Design = KeyboardButtonDesign
    typealias ViewModel = KeyboardButtonViewModelProtocol

    // MARK: - Public Instance Properties

    override var isHighlighted: Bool {
        get { return false }
        set {}
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

    fileprivate lazy var contentView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = design.foregroundColor
        view.layer.masksToBounds = true
        view.layer.cornerRadius = design.cornerRadius - 1 
        view.layer.cornerCurve = .continuous
        return view
    }()
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.textColor = Colors.keyboardButtonContent
        label.font = design.labelFont
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.isHidden = true
        imageView.tintColor = Colors.keyboardButtonContent
        return imageView
    }()

    // MARK: - Private Instance Properties

    fileprivate let viewModel: ViewModel
    fileprivate let design: Design
    fileprivate var updatesHighlightedStateFromNativeControl: Bool { return true }

    private let layerShadow = CALayer.Shadow(color: .black, alpha: 0.75, x: 0, y: 4, blur: 16, spread: -4)

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

    // MARK: - Public Instance Methods

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let outsideFrame = CGRect(
            x: bounds.origin.x - design.touchOutset.left,
            y: bounds.origin.y - design.touchOutset.top,
            width: bounds.width + design.touchOutset.left + design.touchOutset.right,
            height: bounds.height + design.touchOutset.top + design.touchOutset.bottom
        )

        return outsideFrame.contains(point)
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        backgroundColor = design.backgroundColor
        layer.masksToBounds = true
        layer.cornerCurve = .continuous
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
        self.addTarget(self, action: #selector(handleTouchUpInside), for: .touchUpInside)
        self.addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(handleDragExit), for: .touchDragExit)
        self.addTarget(self, action: #selector(handleDragEnter), for: .touchDragEnter)

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

    @objc private func handleTouchUpInside() {
        viewModel.didTapEvent.onNext(viewModel.content)

        guard updatesHighlightedStateFromNativeControl else { return }
        handleIsHighlightedChanged(false)
    }

    @objc private func handleTouchDown() {
        if let soundID = design.pressSoundID {
            AudioServicesPlaySystemSound(soundID)
        }

        guard updatesHighlightedStateFromNativeControl else { return }
        handleIsHighlightedChanged(true)
    }

    @objc private func handleDragEnter() {
        guard updatesHighlightedStateFromNativeControl else { return }
        handleIsHighlightedChanged(true)
    }

    @objc private func handleDragExit() {
        guard updatesHighlightedStateFromNativeControl else { return }
        handleIsHighlightedChanged(false)
    }

    fileprivate func handleIsHighlightedChanged(_ value: Bool) {
        switch (design.isMagnificationEnabled, viewModel.content) {
        case (true, .text):
            if let superview = self.superview {
                if value {
                    superview.bringSubviewToFront(self)
                    transform = .init(translationX: 0, y: -intrinsicContentSize.height)
                        .concatenating(.init(scaleX: 1.5, y: 1.5))
                    layer.applyShadow(layerShadow)
                } else {
                    transform = .identity
                    layer.applyShadow(.none)
                }
            }
        default:
            break
        }

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

        caseChangeViewModel.isCapitalizedEvent.subscribe(self) { isCapitalized in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.contentView.backgroundColor = isCapitalized ?
                    design.highlightedForegroundColor :
                    design.foregroundColor
            }
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
