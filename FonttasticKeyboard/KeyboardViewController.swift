//
//  KeyboardViewController.swift
//  FontasticKeyboard
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import Cartography
import FonttasticTools

class KeyboardViewController: UIInputViewController {

    // MARK: - Private Instance Properties

    private var fontasticKeyboardView: FontasticKeyboardView?

    private var colorPickerCompletion: ((UIColor) -> Void)?
    private weak var colorPickerViewController: UIColorPickerViewController?

    // MARK: - Public Instance Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        FonttasticLogger.shared.setup(with: .default)

        self.fontasticKeyboardView = FontasticKeyboardView(
            initiallySelectedCanvasViewDesign: DefaultFontsService.shared.lastUsedCanvasViewDesign
        )

        setupLayout()
        setupBusinessLogic()

        DefaultFontsService.shared.installFonts { [weak self] in
            guard let fontasticKeyboardView = self?.fontasticKeyboardView else { return }
            let selectedFontModel = fontasticKeyboardView.canvasWithSettingsView.canvasFontModel
            fontasticKeyboardView.canvasWithSettingsView.canvasFontModel = selectedFontModel
        }
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        let isPortrait: Bool = UIScreen.main.isPortrait
        coordinator.animate { [weak self] _ in
            self?.fontasticKeyboardView?.adaptToOrientationChange(isPortrait: isPortrait)
        }
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        guard let fontasticKeyboardView = self.fontasticKeyboardView else { return }
        view.addSubview(fontasticKeyboardView)
        constrain(view, fontasticKeyboardView) { view, keyboard in
            keyboard.edges == view.edges
        }
    }

    private func setupBusinessLogic() {
        guard let fontasticKeyboardView = self.fontasticKeyboardView else { return }

        fontasticKeyboardView.canvasWithSettingsView.shouldToggleFontSelection
            .subscribe(self) { [weak self] in
                self?.showFontPickerViewController()
            }

        fontasticKeyboardView.canvasWithSettingsView.shouldPresentBackgroundColorPickerEvent
            .subscribe(self) { [weak self] in
                self?.showColorPickerViewControllerForBackgroundColor()
            }

        fontasticKeyboardView.canvasWithSettingsView.shouldPresentTextColorPickerEvent
            .subscribe(self) { [weak self] in
                self?.showColorPickerViewControllerForTextColor()
            }
    }

    private func showFontPickerViewController() {
        guard let fontasticKeyboardView = self.fontasticKeyboardView else { return }
        let fontSelectionViewController = FontSelectionController(
            initiallySelectedFontModel: fontasticKeyboardView.canvasWithSettingsView.canvasFontModel
        )
        fontSelectionViewController.delegate = self

        let nav = BaseNavigationController(rootViewController: fontSelectionViewController)
        present(nav, animated: true)
    }

    private func showColorPickerViewControllerForBackgroundColor() {
        guard let fontasticKeyboardView = self.fontasticKeyboardView else { return }
        showColorPickerViewController(
            selectedColor: fontasticKeyboardView.canvasWithSettingsView.canvasBackgroundColor
        ) { [weak self] color in
            self?.fontasticKeyboardView?.canvasWithSettingsView.canvasBackgroundColor = color
        }
    }

    private func showColorPickerViewControllerForTextColor() {
        guard let fontasticKeyboardView = self.fontasticKeyboardView else { return }
        showColorPickerViewController(
            selectedColor: fontasticKeyboardView.canvasWithSettingsView.canvasTextColor
        ) { [weak self] color in
            self?.fontasticKeyboardView?.canvasWithSettingsView.canvasTextColor = color
        }
    }

    private func showColorPickerViewController(
        selectedColor: UIColor,
        completion: @escaping (UIColor) -> Void
    ) {
        if let colorPickerViewController = colorPickerViewController {
            colorPickerViewController.dismiss(animated: true)
        }

        let colorPickerViewController = UIColorPickerViewController()
        colorPickerViewController.selectedColor = selectedColor
        colorPickerViewController.supportsAlpha = false
        colorPickerViewController.delegate = self

        self.colorPickerViewController = colorPickerViewController
        self.colorPickerCompletion = completion

        self.present(colorPickerViewController, animated: true)
    }
}

extension KeyboardViewController: FontSelectionControllerDelegate {

    // MARK: - Internal Instance Methods

    func didSelectFontModel(_ fontModel: FontModel) {
        setFontModelToCanvas(fontModel)
    }

    func didCancelFontSelection(_ initiallySelectedFontModel: FontModel) {
        setFontModelToCanvas(initiallySelectedFontModel)
    }

    func didFinishFontSelection() {
        guard let fontasticKeyboardView = self.fontasticKeyboardView else { return }
        let selectedFontModel = fontasticKeyboardView.canvasWithSettingsView.canvasFontModel
        logger.log(
            "Finished font selection",
            description: "Selected FontModel: \(selectedFontModel)",
            level: .info
        )
    }

    // MARK: - Private Instance Methods

    private func setFontModelToCanvas(_ fontModel: FontModel) {
        fontasticKeyboardView?.canvasWithSettingsView.canvasFontModel = fontModel
    }
}

extension KeyboardViewController: UIColorPickerViewControllerDelegate {

    func colorPickerViewController(
        _ viewController: UIColorPickerViewController,
        didSelect color: UIColor,
        continuously: Bool
    ) {
        guard let completion = colorPickerCompletion else { return }
        completion(viewController.selectedColor)
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        guard let completion = colorPickerCompletion else { return }
        completion(viewController.selectedColor)
        colorPickerCompletion = nil
    }
}
