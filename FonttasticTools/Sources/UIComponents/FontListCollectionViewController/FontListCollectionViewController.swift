//
//  FontListViewController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit
import Cartography

public class FontListCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Subviews
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = FonttasticToolsAsset.bg.image
        return imageView
    }()
    private let collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = Constants.spacing
        layout.minimumInteritemSpacing = Constants.spacing
        layout.sectionInset = .init(vertical: Constants.spacing, horizontal: Constants.spacing)
        return layout
    }()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)

    // MARK: - Private Properties

    private let viewModel: FontListCollectionViewModel
    private let columnsCount: Int = {
        let screenWidth = UIScreen.main.bounds.width

        if screenWidth >= 600.0 {
            return 5
        } else if screenWidth >= 375.0 {
            return 3
        }

        return 2
    }()

    private var cachedCollectionViewBoundingWidth: CGFloat?
    private var cachedFontCellBoundingWidth: CGFloat?
    private var cachedFontCellRowHeights: [Int: CGFloat] = [:]

    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .soft)

    // MARK: - Initializers

    public init(viewModel: FontListCollectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        setupLayout()
        setupBusinessLogic()
        reloadData()
    }

    // MARK: - Private Methods

    private func setupLayout() {
        view.addSubview(backgroundImageView)
        constrain(view, backgroundImageView) { view, background in
            background.edges == view.edges
        }
        setupCollectionView()
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        constrain(view, collectionView) { view, collection in
            collection.edges == view.edges
        }

        collectionView.backgroundColor = .clear
        collectionView.contentInset.bottom = 16
        collectionView.isMultipleTouchEnabled = false
        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = false

        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func setupBusinessLogic() {
        viewModel.shouldReloadDataEvent.subscribe(self) { [weak self] in
            self?.reloadData()
        }
    }

    private func reloadData() {
        cachedCollectionViewBoundingWidth = nil
        cachedFontCellBoundingWidth = nil
        cachedFontCellRowHeights = [:]

        collectionView.reloadData()
    }
}

extension FontListCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sections.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let section = viewModel.sections[safe: section] else { return 0 }
        switch section {
        case .title, .banner, .loader:
            return 1

        case let .fontList(sectionModel):
            return sectionModel.fontViewModels.count
        }
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let section = viewModel.sections[safe: indexPath.section] else { return UICollectionViewCell() }
        switch section {
        case let .banner(sectionModel):
            return bannerCell(
                collectionView: collectionView,
                indexPath: indexPath,
                viewModel: sectionModel.bannerViewModel,
                design: sectionModel.bannerDesign
            )

        case let .title(sectionModel):
            return titleCell(
                collectionView: collectionView,
                indexPath: indexPath,
                viewModel: sectionModel.titleViewModel,
                design: sectionModel.titleDesign
            )

        case let .fontList(sectionModel):
            guard
                let fontViewModel = sectionModel.fontViewModels[safe: indexPath.item]
            else { return UICollectionViewCell() }

            return fontCell(
                collectionView: collectionView,
                indexPath: indexPath,
                viewModel: fontViewModel
            )

        case let .loader(sectionModel):
            return loaderCell(
                collectionView: collectionView,
                indexPath: indexPath,
                design: sectionModel.loaderDesign
            )
        }
    }

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        impactFeedbackGenerator.prepare()
        return true
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let section = viewModel.sections[safe: indexPath.section] else { return }

        switch section {
        case let .banner(sectionModel):
            impactFeedbackGenerator.impactOccurred()
            sectionModel.bannerViewModel.didTapEvent.onNext(())

        case let .fontList(sectionModel):
            guard
                let fontViewModel = sectionModel.fontViewModels[safe: indexPath.item]
            else { return }

            impactFeedbackGenerator.impactOccurred()
            viewModel.didTapFontCell.onNext(fontViewModel)

        case .title, .loader:
            break
        }
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let section = viewModel.sections[safe: indexPath.section] else { return .zero }

        let boundingWidth: CGFloat
        if let cachedBoundingWidth = self.cachedCollectionViewBoundingWidth {
            boundingWidth = cachedBoundingWidth
        } else {
            boundingWidth = collectionView.bounds.width - self.collectionViewLayout.sectionInset.horizontalSum
        }

        switch section {
        case let .banner(sectionModel):
            let height = FontListBannerCell.height(
                boundingWidth: boundingWidth,
                viewModel: sectionModel.bannerViewModel,
                design: sectionModel.bannerDesign
            )
            return CGSize(width: boundingWidth, height: height)

        case let .title(sectionModel):
            let height = FontListTitleCell.height(
                boundingWidth: boundingWidth,
                viewModel: sectionModel.titleViewModel,
                design: sectionModel.titleDesign
            )
            return CGSize(width: boundingWidth, height: height)

        case let .fontList(sectionModel):
            guard indexPath.item < sectionModel.fontViewModels.count else { return .zero }

            let fontCellBoundingWidth: CGFloat
            if let cachedFontCellBoundingWidth = self.cachedFontCellBoundingWidth {
                fontCellBoundingWidth = cachedFontCellBoundingWidth
            } else {
                let columnsSpacing = CGFloat(self.columnsCount - 1) * self.collectionViewLayout.minimumInteritemSpacing
                fontCellBoundingWidth = floor((boundingWidth - columnsSpacing) / CGFloat(self.columnsCount))
                cachedFontCellBoundingWidth = fontCellBoundingWidth
            }
            let rowHeight = fontCellRowHeight(
                index: indexPath.item,
                fontCellViewModels: sectionModel.fontViewModels,
                boundingWidth: fontCellBoundingWidth
            )
            return CGSize(width: fontCellBoundingWidth, height: rowHeight)

        case let .loader(sectionModel):
            return CGSize(
                width: boundingWidth,
                height: FontListLoaderCell.height(design: sectionModel.loaderDesign)
            )
        }
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        guard let section = viewModel.sections[safe: section] else { return .zero }

        return section.sectionInsets
    }

    // MARK: - Utils

    private func fontCellRowHeight(
        index: Int,
        fontCellViewModels: [FontListFontViewModel],
        boundingWidth: CGFloat
    ) -> CGFloat {
        let rowIndex = index / columnsCount
        if let cachedRowHeight = cachedFontCellRowHeights[rowIndex] {
            return cachedRowHeight
        }

        let startIndex = rowIndex * columnsCount
        let endIndex = startIndex + columnsCount
        let rowViewModels = fontCellViewModels[safeRange: startIndex..<endIndex]

        var maxCellHeight: CGFloat = 0
        rowViewModels.forEach { viewModel in
            let cellHeight = FontListFontCell.height(for: viewModel, boundingWidth: boundingWidth)
            if cellHeight > maxCellHeight {
                maxCellHeight = cellHeight
            }
        }

        cachedFontCellRowHeights[rowIndex] = maxCellHeight
        return maxCellHeight
    }

    private func bannerCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        viewModel: FontListBannerCell.ViewModel,
        design: FontListBannerCell.Design
    ) -> UICollectionViewCell {
        let cell: FontListBannerCell = collectionView.registerAndDequeueReusableCell(for: indexPath)
        cell.apply(viewModel: viewModel, design: design)
        return cell
    }

    private func titleCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        viewModel: FontListTitleCell.ViewModel,
        design: FontListTitleCell.Design
    ) -> UICollectionViewCell {
        let cell: FontListTitleCell = collectionView.registerAndDequeueReusableCell(for: indexPath)
        cell.apply(viewModel: viewModel, design: design)
        return cell
    }

    private func fontCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        viewModel: FontListFontViewModel
    ) -> UICollectionViewCell {
        let cell: FontListFontCell = collectionView.registerAndDequeueReusableCell(for: indexPath)
        cell.apply(viewModel: viewModel)
        return cell
    }

    private func loaderCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        design: FontListLoaderCell.Design
    ) -> UICollectionViewCell {
        let cell: FontListLoaderCell = collectionView.registerAndDequeueReusableCell(for: indexPath)
        cell.apply(design: design)
        cell.startAnimating()
        return cell
    }
}

private enum Constants {

    static let spacing: CGFloat = 16.0
}
