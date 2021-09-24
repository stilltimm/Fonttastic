//
//  FontListViewController.swift
//  Fontastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit

class FontListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Private Properties

    private let fontsRepository: FontsRepository = DefaultFontsRepository()
    private let fontCellIdentifier: String = "FontCell"
    private var exampleText: String = "Quick brown fox jumps over the lazy dog"

    // MARK: - Initializers

    init() {
        let layout = UICollectionViewFlowLayout()
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
    }

    // MARK: -

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fontsRepository.fonts.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let fontModel = fontsRepository.fonts[safe: indexPath.row] else {
            return UICollectionViewCell()
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: fontCellIdentifier, for: indexPath)
        guard let fontCell = cell as? FontListFontTableViewCell else {
            return UICollectionViewCell()
        }

        fontCell.apply(viewModel: .init(fontName: fontModel.name, exampleText: exampleText))

        return fontCell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: Constants.rowHeight)
    }

    // MARK: - Private Methods

    private func setupLayout() {
        collectionView.backgroundColor = .clear
        collectionView.register(FontListFontTableViewCell.self, forCellWithReuseIdentifier: fontCellIdentifier)
        collectionView.contentInset.bottom = 16
        collectionView.isMultipleTouchEnabled = false
        collectionView.delegate = self
    }

    private func reloadData() {
        collectionView.reloadData()
    }
}

private enum Constants {

    static let title = "Мои шрифты"

    static let rowHeight: CGFloat = 82
}
