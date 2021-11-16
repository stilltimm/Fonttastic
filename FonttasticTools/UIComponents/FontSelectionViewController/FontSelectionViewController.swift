//
//  FontSelectionViewController.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 15.11.2021.
//

import UIKit
import Cartography

public protocol FontSelectionControllerDelegate: AnyObject {

    func didSelectFontModel(_ fontModel: FontModel)
    func didCancelFontSelection(_ initiallySelectedFontModel: FontModel)
    func didFinishFontSelection()
}

public class FontSelectionController: UIViewController {

    // MARK: - Public Instance Properties

    public weak var delegate: FontSelectionControllerDelegate?

    // MARK: - Private Instance Properties

    private let initiallySelectedFontModel: FontModel
    private let fontListCollectionViewModel = FontListCollectionViewModel(mode: .fontSelection)
    private let fontListCollectionViewController: FontListCollectionViewController

    public init(initiallySelectedFontModel: FontModel) {
        self.initiallySelectedFontModel = initiallySelectedFontModel
        self.fontListCollectionViewController = FontListCollectionViewController(
            viewModel: fontListCollectionViewModel
        )

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.backgroundMain

        setupNavigationBar()
        setupLayout()
        setupBusinessLogic()
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = Constants.title

        navigationController?.navigationBar.titleTextAttributes?[.font] = UIFont(
            name: "AvenirNext-Medium",
            size: 24
        )

        navigationItem.setRightBarButton(
            UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(self.handleFontSelectionFinish)
            ),
            animated: false
        )
        navigationItem.setLeftBarButton(
            UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(self.handleFontSelectionCancel)
            ),
            animated: false
        )
    }

    private func setupLayout() {
        setupFontListCollectionViewController()
    }

    private func setupFontListCollectionViewController() {
        addChild(fontListCollectionViewController)
        view.addSubview(fontListCollectionViewController.view)
        fontListCollectionViewController.didMove(toParent: self)

        constrain(view, fontListCollectionViewController.view) { view, fontListCollection in
            fontListCollection.edges == view.edges
        }
    }

    private func setupBusinessLogic() {
        fontListCollectionViewModel.didTapFontCell.subscribe(self) { [weak self] fontListFontViewModel in
            self?.delegate?.didSelectFontModel(fontListFontViewModel.fontModel)
        }
    }

    @objc private func handleFontSelectionFinish() {
        delegate?.didFinishFontSelection()
        dismiss(animated: true)
    }

    @objc private func handleFontSelectionCancel() {
        delegate?.didCancelFontSelection(initiallySelectedFontModel)
        dismiss(animated: true)
    }
}

private enum Constants {

    static let title: String = "Select Font"
}
