//
//  FontListBannerCell.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 06.10.2021.
//

import UIKit
import Cartography

class FontListBannerCell: UICollectionViewCell, Reusable {

    // MARK: - Nested Types

    struct ViewModel {
        let title: String
        let didTapEvent = Event<Void>()
    }

    struct Design {
        let minHeightToWidthAspectRatio: CGFloat
        let contentInsets: UIEdgeInsets
        let font: UIFont
        let textColor: UIColor
        let backgroundColor: UIColor
        let cornerRadius: CGFloat
        let shadow: CALayer.Shadow?
    }

    // MARK: - Public Type Methods

    static func height(
        boundingWidth: CGFloat,
        viewModel: ViewModel,
        design: Design
    ) -> CGFloat {
        let attributedString = NSAttributedString(
            string: viewModel.title,
            attributes: [
                .font: design.font
            ]
        )
        let containerWidth = boundingWidth - Constants.edgeInsets.horizontalSum
        let titleBoundingWidth = containerWidth - design.contentInsets.horizontalSum
        let boundingRect = attributedString.boundingRect(
            with: CGSize(width: titleBoundingWidth, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            context: nil
        )
        let titleWithInsetsHeight = ceil(boundingRect.height) + design.contentInsets.verticalSum

        let containerHeight: CGFloat
        if titleWithInsetsHeight / containerWidth > design.minHeightToWidthAspectRatio {
            containerHeight = titleWithInsetsHeight
        } else {
            containerHeight = ceil(containerWidth * design.minHeightToWidthAspectRatio)
        }

        return containerHeight + Constants.edgeInsets.verticalSum
    }

    // MARK: - Subviews

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerCurve = .continuous
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    // MARK: - Public Instance Properties

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withConfig: .fastControl) {
                self.transform = self.isHighlighted ?
                    CGAffineTransform.init(scaleX: 0.95, y: 0.95) :
                    .identity
            }
        }
    }

    // MARK: - Private Instance Properties

    private(set) var viewModel: ViewModel?
    private var design: Design?

    private var titleLeftInsetConstraint: NSLayoutConstraint?
    private var titleRightInsetConstraint: NSLayoutConstraint?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Instance Methods

    override func prepareForReuse() {
        super.prepareForReuse()

        viewModel = nil
        design = nil
        titleLabel.text = nil
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        applyShadowIfNeeded()
    }

    func apply(viewModel: ViewModel, design: Design) {
        self.viewModel = viewModel
        self.design = design

        containerView.backgroundColor = design.backgroundColor
        containerView.layer.cornerRadius = design.cornerRadius

        titleLabel.font = design.font
        titleLabel.textColor = design.textColor
        titleLabel.text = viewModel.title

        titleLeftInsetConstraint?.constant = design.contentInsets.left
        titleRightInsetConstraint?.constant = -design.contentInsets.right
    }

    func applyShadowIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let shadow = self.design?.shadow {
                self.containerView.layer.applyShadow(shadow)
            }
        }
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        constrain(contentView, containerView, titleLabel) { contentView, container, titleLabel in
            container.edges == contentView.edges.inseted(by: Constants.edgeInsets)
            self.titleLeftInsetConstraint = (titleLabel.left == container.left)
            self.titleRightInsetConstraint = (titleLabel.right == container.right)
            titleLabel.centerY == container.centerY
        }
    }
}

private enum Constants {

    static let edgeInsets: UIEdgeInsets = .init(
        top: 0,
        left: 0,
        bottom: 0,
        right: 0
    )
}
