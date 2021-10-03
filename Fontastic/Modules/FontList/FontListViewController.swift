//
//  FontListViewController.swift
//  Fontastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit
import Cartography

class FontListViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Subviews

    private let collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = Constants.spacing
        layout.minimumInteritemSpacing = Constants.spacing
        layout.sectionInset = .init(vertical: Constants.spacing, horizontal: Constants.spacing)
        return layout
    }()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)

    // MARK: - Private Properties

    private let fontsService: FontsService = DefaultFontsService.shared
    private let fontsRepository: FontsRepository = DefaultFontsRepository.shared
    private var fontViewModels: [FontListFontViewModel] = []
    private let fontCellIdentifier: String = "FontCell"

    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .soft)

    private let columnsCount: Int = 2

    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.backgroundMain
        navigationItem.title = Constants.title

        setupLayout()
        reloadData()

        fontsRepository.didUpdateFontsEvent.subscribe(self) { [weak self] in
            self?.reloadData()
        }
    }

    // MARK: - Private Methods

    private func setupLayout() {
        view.addSubview(collectionView)
        constrain(view, collectionView) { view, collection in
            collection.edges == view.edges
        }

        collectionView.backgroundColor = .clear
        collectionView.register(
            FontListFontTableViewCell.self,
            forCellWithReuseIdentifier: fontCellIdentifier
        )
        collectionView.contentInset.bottom = 16
        collectionView.isMultipleTouchEnabled = false
        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = false
    }

    private func reloadData() {
        fontViewModels = fontsRepository.fonts.map { FontListFontViewModel(withModel: $0) }
        collectionView.reloadData()
    }

    private func openFontDetails(_ fontModel: FontModel) {
        let fontDetailsViewController = FontDetailsViewController(fontModel: fontModel)
        navigationController?.pushViewController(fontDetailsViewController, animated: true)
    }

    private func installFont(from fontSourceModel: FontSourceModel) {
        fontsService.installFont(from: fontSourceModel) { result in
            switch result {
            case let .success(fontModel):
                print("Successfully installed font \(fontModel)")

            case let .failure(error):
                print("Failed to installed font from source \(fontSourceModel) with error \(error)")
            }
        }
    }
}

extension FontListViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return fontViewModels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let fontViewModel = fontViewModels[safe: indexPath.row] else {
            return UICollectionViewCell()
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: fontCellIdentifier, for: indexPath)
        guard let fontCell = cell as? FontListFontTableViewCell else {
            return UICollectionViewCell()
        }

        fontCell.apply(viewModel: fontViewModel)

        return fontCell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let cellViewModel = fontViewModels[safe: indexPath.item] else { return }

        impactFeedbackGenerator.impactOccurred()
        switch cellViewModel.action {
        case let .installFont(source):
            installFont(from: source)

        case let .openDetails(fontModel):
            openFontDetails(fontModel)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let viewModel = fontViewModels[safe: indexPath.item] else { return .zero }

        let columnsSpacing = CGFloat(self.columnsCount - 1) * self.collectionViewLayout.minimumInteritemSpacing
        let estimatedWidth = collectionView.bounds.width
            - self.collectionViewLayout.sectionInset.horizontalSum
            - columnsSpacing
        let cellWidth = floor(estimatedWidth)
        let cellHeight = FontListFontTableViewCell.height(
            for: viewModel,
            boundingWidth: cellWidth
        )
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

private enum Constants {

    static let spacing: CGFloat = 16.0
    static let title = "Fontastic"
}
