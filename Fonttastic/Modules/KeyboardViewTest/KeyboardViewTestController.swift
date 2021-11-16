//
//  KeyboardViewTestController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import Cartography
import FonttasticTools

class KeyboardViewTestViewController: UIViewController {

    // MARK: - Subviews

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.backgroundColor = .clear
        scrollView.canCancelContentTouches = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private let fontasticKeyboardView: FontasticKeyboardView

    // MARK: - Private Instance Properties

    private let fontsService: FontsService = DefaultFontsService.shared

    // MARK: - Initializers

    init() {
        self.fontasticKeyboardView = FontasticKeyboardView(
            initiallySelectedFontModel: fontsService.lastUsedFontModel
        )

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Keyboard View"

        setupLayout()
        setupBusinessLogic()
    }

    // MARK: - Private Methods

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.backgroundColor = Colors.backgroundMain

        containerView.addSubview(fontasticKeyboardView)
        constrain(
            view, scrollView, containerView, fontasticKeyboardView
        ) { (view, scrollView, container, keyboard) in
            scrollView.edges == view.edges

            (container.width == view.width).priority = .required
            container.height == UIScreen.main.bounds.height

            keyboard.center == container.center
            keyboard.width == container.width
        }
    }

    private func setupBusinessLogic() {
        fontasticKeyboardView.canvasWithSettingsView.shouldToggleFontSelection.subscribe(self) { [weak self] in
            self?.presentFontPickerViewController()
        }
    }

    private func presentFontPickerViewController() {
        let fontSelectionViewController = FontSelectionController(
            initiallySelectedFontModel: fontasticKeyboardView.canvasWithSettingsView.canvasFontModel
        )
        fontSelectionViewController.delegate = self
        let nav = BaseNavigationController(rootViewController: fontSelectionViewController)
        present(nav, animated: true)
    }
}

extension KeyboardViewTestViewController: FontSelectionControllerDelegate {

    // MARK: - Internal Instance Methods

    func didSelectFontModel(_ fontModel: FontModel) {
        setFontModelToCanvas(fontModel)
    }

    func didCancelFontSelection(_ initiallySelectedFontModel: FontModel) {
        setFontModelToCanvas(initiallySelectedFontModel)
    }

    func didFinishFontSelection() {
        let selectedFontModel = fontasticKeyboardView.canvasWithSettingsView.canvasFontModel
        logger.log(
            "Finished font selection",
            description: "Selected FontModel: \(selectedFontModel)",
            level: .info
        )
    }

    // MARK: - Private Instance Methods

    private func setFontModelToCanvas(_ fontModel: FontModel) {
        fontasticKeyboardView.canvasWithSettingsView.canvasFontModel = fontModel
        fontsService.lastUsedFontModel = fontModel
    }
}
