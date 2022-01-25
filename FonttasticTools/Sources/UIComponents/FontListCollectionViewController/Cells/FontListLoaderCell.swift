//
//  FontListLoaderCell.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 15.11.2021.
//

import UIKit
import Cartography

class FontListLoaderCell: UICollectionViewCell, Reusable {

    // MARK: - Nested Types

    struct Design {
        let height: CGFloat
    }

    // MARK: - Public Type Methods

    static func height(design: Design) -> CGFloat {
        return design.height
    }

    // MARK: - Subviews

    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Private Instance Properties

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

        design = nil
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }

    func apply(design: Design) {
        self.design = design
    }

    func startAnimating() {
        activityIndicator.startAnimating()
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        contentView.addSubview(activityIndicator)
        constrain(contentView, activityIndicator) { contentView, activityIndicator in
            activityIndicator.center == contentView.center
        }
    }
}
