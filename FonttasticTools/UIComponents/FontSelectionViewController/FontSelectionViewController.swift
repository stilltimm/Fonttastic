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
    private let keyboardLanguage: KeyboardType.Language

    private let fontListCollectionViewModel: FontListCollectionViewModel
    private let fontListCollectionViewController: FontListCollectionViewController

    public init(
        initiallySelectedFontModel: FontModel,
        keyboardLanguage: KeyboardType.Language
    ) {
        self.initiallySelectedFontModel = initiallySelectedFontModel
        self.keyboardLanguage = keyboardLanguage

        self.fontListCollectionViewModel = FontListCollectionViewModel(
            mode: .fontSelection(language: keyboardLanguage)
        )
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
        navigationItem.title = Strings.fontSelectionTitle
        navigationItem.prompt = promptText(for: keyboardLanguage)

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

    private func promptText(for language: KeyboardType.Language) -> String {
        switch language {
        case .latin:
            return Strings.fontSelectionPromptLatinFonts

        case .cyrillic:
            return Strings.fontSelectionPromptCyrillicFonts
        }
    }
}
