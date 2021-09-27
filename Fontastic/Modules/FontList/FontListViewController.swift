//
//  FontListViewController.swift
//  Fontastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit

class FontListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Private Properties

    private let fontsService: FontsService = DefaultFontsService.shared
    private let fontsRepository: FontsRepository = DefaultFontsRepository.shared
    private var fontViewModels: [FontListFontViewModel] = []
    private let fontCellIdentifier: String = "FontCell"

    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .soft)

    // MARK: - Initializers

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        super.init(collectionViewLayout: layout)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.backgroundMinor
        navigationItem.title = Constants.title

        setupLayout()
        reloadData()

        fontsRepository.didUpdateFontsEvent.subscribe(self) { [weak self] in
            self?.reloadData()
        }
    }

    // MARK: -

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return fontViewModels.count
    }

    override func collectionView(
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

    override func collectionView(
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
        let cellWidth = collectionView.bounds.width
        let cellHeight = FontListFontTableViewCell.height(
            for: viewModel,
            boundingWidth: cellWidth
        )
        return CGSize(width: cellWidth, height: cellHeight)
    }

    // MARK: - Private Methods

    private func setupLayout() {
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

private enum Constants {

    static let title = "Мои шрифты"
}
