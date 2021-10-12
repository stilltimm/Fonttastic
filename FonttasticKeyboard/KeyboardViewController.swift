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

    private let fontasticKeyboardView = FontasticKeyboardView()

    private var colorPickerCompletion: ((UIColor) -> Void)?
    private weak var colorPickerViewController: UIColorPickerViewController?

    // MARK: - Public Instance Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupBusinessLogic()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        view.addSubview(fontasticKeyboardView)
        constrain(view, fontasticKeyboardView) { view, keyboard in
            keyboard.edges == view.edges
        }
    }

    private func setupBusinessLogic() {
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
        let config = UIFontPickerViewController.Configuration()
        config.displayUsingSystemFont = false
        config.includeFaces = true
        let fontPickerViewController = UIFontPickerViewController(configuration: config)

        fontPickerViewController.delegate = self

        present(fontPickerViewController, animated: true)
    }

    private func showColorPickerViewControllerForBackgroundColor() {
        showColorPickerViewController(
            selectedColor: fontasticKeyboardView.canvasWithSettingsView.canvasBackgroundColor
        ) { [weak self] color in
            self?.fontasticKeyboardView.canvasWithSettingsView.canvasBackgroundColor = color
        }
    }

    private func showColorPickerViewControllerForTextColor() {
        showColorPickerViewController(
            selectedColor: fontasticKeyboardView.canvasWithSettingsView.canvasTextColor
        ) { [weak self] color in
            self?.fontasticKeyboardView.canvasWithSettingsView.canvasTextColor = color
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

extension KeyboardViewController: UIFontPickerViewControllerDelegate {

    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        guard let descriptor = viewController.selectedFontDescriptor else { return }
        let font = UIFont(descriptor: descriptor, size: 36.0)
        fontasticKeyboardView.canvasWithSettingsView.canvasLabelFont = font
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
