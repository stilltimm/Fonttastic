//
//  KeyboardViewController.swift
//  FontasticKeyboard
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import Cartography
import FonttasticTools
import Photos
import PhotosUI

class KeyboardViewController: UIInputViewController {

    // MARK: - Private Instance Properties

    private var fontasticKeyboardView: FontasticKeyboardView?
    private var lockOverlayView: KeyboardLockOverlayView?

    private var colorPickerCompletion: ((UIColor) -> Void)?
    private weak var colorPickerViewController: UIColorPickerViewController?

    private lazy var phImageManager = PHImageManager()

    // MARK: - Public Instance Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        FonttasticLogger.shared.setup(with: .default)

        self.fontasticKeyboardView = FontasticKeyboardView(
            insertedText: [],
            initiallySelectedCanvasViewDesign: DefaultFontsService.shared.lastUsedCanvasViewDesign
        )
        self.lockOverlayView = KeyboardLockOverlayView()

        setupLayout()
        setupBusinessLogic()

        DefaultFontsService.shared.installFonts { [weak self] in
            guard let fontasticKeyboardView = self?.fontasticKeyboardView else { return }
            let selectedFontModel = fontasticKeyboardView.canvasWithSettingsView.canvasFontModel
            fontasticKeyboardView.canvasWithSettingsView.canvasFontModel = selectedFontModel
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        DefaultFontsService.shared.storeLastUsedSettings()
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        let isPortrait: Bool = UIScreen.main.isPortrait
        coordinator.animate { [weak self] _ in
            self?.fontasticKeyboardView?.adaptToOrientationChange(isPortrait: isPortrait)
            self?.lockOverlayView?.adaptToOrientationChange(isPortrait: isPortrait)
        }
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        if let fontasticKeyboardView = self.fontasticKeyboardView {
            view.addSubview(fontasticKeyboardView)
            constrain(view, fontasticKeyboardView) { view, keyboard in
                keyboard.edges == view.edges
            }
        }

        if let lockOverlayView = lockOverlayView {
            view.addSubview(lockOverlayView)
            constrain(view, lockOverlayView) { view, overlay in
                overlay.edges == view.edges
            }
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

        fontasticKeyboardView.canvasWithSettingsView.shouldPresentBackgroundImageSelectionEvent
            .subscribe(self) { [weak self] in
                self?.showBackgroundColorSelectionController()
            }
        fontasticKeyboardView.canvasWithSettingsView.shouldPresentTextColorPickerEvent
            .subscribe(self) { [weak self] in
                self?.showColorPickerViewControllerForTextColor()
            }

        if let lockOverlayView = lockOverlayView {
            fontasticKeyboardView.alpha = 0.1
            lockOverlayView.didTapEvent.subscribe(self) { [weak self] in
                self?.openApp(urlString: Constants.openAppUrlString)
            }
        }
    }

    @objc func openURL(_ url: URL) {}

    func openApp(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        var responder: UIResponder? = self as UIResponder
        let selector = #selector(openURL(_:))

        while responder != nil {
            if responder?.responds(to: selector) == true && responder != self {
                responder?.perform(selector, with: url)
                return
            }
            responder = responder?.next
        }
    }

    private func showFontPickerViewController() {
        guard let fontasticKeyboardView = self.fontasticKeyboardView else { return }
        let fontSelectionViewController = FontSelectionController(
            initiallySelectedFontModel: fontasticKeyboardView.canvasWithSettingsView.canvasFontModel,
            keyboardLanguage: fontasticKeyboardView.lastUsedLanguage
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

    private func showBackgroundColorSelectionController() {
        DefaultPhotosAccessService.shared.grantPhotosAccess { [weak self] accessGranted in
            guard let self = self else { return }
            guard accessGranted else {
                return
            }

            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            configuration.filter = .images
            configuration.selectionLimit = 1
            let photoPickerViewController = PHPickerViewController(configuration: configuration)
            photoPickerViewController.delegate = self

            self.present(photoPickerViewController, animated: true)
        }
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

extension KeyboardViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let fontasticKeyboardView = fontasticKeyboardView else { return }

        guard let result = results.first, let assetIdentifier = result.assetIdentifier else {
            logger.log("PhotoPicker did finish, but result is empty or has nil assetIdentifier", level: .debug)
            self.dismiss(animated: true)
            return
        }

        guard
            let phAsset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject
        else {
            logger.log("PhotoPicker did finish, but unable to fetch PHAsset", level: .debug)
            self.dismiss(animated: true)
            return
        }

        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        options.resizeMode = .exact
        options.version = .current
        phImageManager.requestImage(
            for: phAsset,
               targetSize: fontasticKeyboardView.canvasWithSettingsView.targetBackgroundImageSize,
               contentMode: .aspectFill,
               options: options
        ) { [weak self] image, info in
            guard let self = self else { return }
            guard let image = image else {
                logger.log(
                    "Failed to fetch image with PHAsset",
                    description: "Info: \(info?.debugDescription ?? "nil")",
                    level: .debug
                )
                self.dismiss(animated: true)
                return
            }
            logger.log(
                "Did fetch image for backgroundImage",
                description: "ImageSize: \(image.size)",
                level: .debug
            )
            self.fontasticKeyboardView?.canvasWithSettingsView.canvasBackgroundImage = image
            self.dismiss(animated: true)
        }
    }
}

private enum Constants {

    static let openAppUrlString = "fonttastic://home"
}
