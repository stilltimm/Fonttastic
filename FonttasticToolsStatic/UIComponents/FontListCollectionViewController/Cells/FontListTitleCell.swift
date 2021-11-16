//
//  FontListTitleCell.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 06.10.2021.
//

import UIKit
import Cartography

class FontListTitleCell: UICollectionViewCell, Reusable {

    // MARK: - Nested Types

    struct ViewModel {
        let title: String
    }

    struct Design {
        let font: UIFont
        let textColor: UIColor
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
        let boundingRect = attributedString.boundingRect(
            with: CGSize(width: boundingWidth, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            context: nil
        )

        return ceil(boundingRect.height)
    }

    // MARK: - Subviews

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Private Instance Properties

    private var viewModel: ViewModel?
    private var design: Design?

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

    func apply(viewModel: ViewModel, design: Design) {
        self.viewModel = viewModel
        self.design = design

        titleLabel.font = design.font
        titleLabel.textColor = design.textColor
        titleLabel.text = viewModel.title
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        contentView.addSubview(titleLabel)
        constrain(contentView, titleLabel) { contentView, titleLabel in
            titleLabel.edges == contentView.edges
        }
    }
}
