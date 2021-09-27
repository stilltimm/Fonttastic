//
//  KeyboardLabelCell.swift
//  FontasticKeyboard
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import Cartography
import FontasticTools

class SymbolButton: UIControl {

    // MARK: - Nested Types

    typealias ViewModel = KeyboardLabelButtonViewModel
    struct Design {
        let backgroundColor: UIColor
        let foregroundColor: UIColor
        let highlightedColor: UIColor
        let shadowSize: CGFloat
        let cornerRadius: CGFloat
        let labelFont: UIFont
    }

    // MARK: - Public Instance Properties

    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? design.highlightedColor : design.foregroundColor
        }
    }

    override var intrinsicContentSize: CGSize {
        switch viewModel.style {
        case let .fixed(width):
            return CGSize(width: width, height: super.intrinsicContentSize.height)

        case let .flexible(flexBasis):
            return CGSize(width: flexBasis, height: super.intrinsicContentSize.height)
        }
    }

    // MARK: - Subviews

    private let contentView = UIView()
    private let symbolLabel = UILabel()

    // MARK: - Private Instance Properties

    private let viewModel: ViewModel
    private let design: Design

    // MARK: - Initializers

    init(viewModel: ViewModel, design: Design) {
        self.viewModel = viewModel
        self.design = design

        super.init(frame: .zero)

        setupLayout()
        self.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handleTap() {
        viewModel.didTapEvent.onNext(viewModel.symbol)
    }

    private func setupLayout() {
        contentView.isUserInteractionEnabled = false
        symbolLabel.isUserInteractionEnabled = false

        backgroundColor = design.backgroundColor
        contentView.backgroundColor = design.foregroundColor

        layer.masksToBounds = true
        contentView.layer.masksToBounds = true

        layer.cornerRadius = design.cornerRadius
        contentView.layer.cornerRadius = design.cornerRadius

        symbolLabel.textColor = .black
        symbolLabel.font = design.labelFont
        symbolLabel.textAlignment = .center

        addSubview(contentView)
        contentView.addSubview(symbolLabel)

        let insets = UIEdgeInsets(top: 0, left: 0, bottom: design.shadowSize, right: 0)
        constrain(
            self, contentView, symbolLabel
        ) { view, content, symbol in
            content.edges == view.edges.inseted(by: insets)
            symbol.leading == content.leading
            symbol.trailing == content.trailing
            symbol.centerY == content.centerY - 2
        }

        symbolLabel.text = viewModel.symbol
        switch viewModel {
        case let .capitalizableSymbol(capitalizableViewModel):
            capitalizableViewModel.didChangeSymbolEvent.subscribe(self) { [weak self] symbol in
                self?.symbolLabel.text = symbol
            }
        default:
            break
        }
    }
}
