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
import RevenueCat

class KeyboardViewController: UIInputViewController {

    // MARK: - Private Instance Properties

    private var fonttasticKeyboardView: FontasticKeyboardView?
    private var lockOverlayView: KeyboardLockOverlayView?

    private var colorPickerCompletion: ((UIColor) -> Void)?
    private weak var colorPickerViewController: UIColorPickerViewController?

    private lazy var phImageManager = PHImageManager()

    // MARK: - Public Instance Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        DefaultConfigurationService.shared.performInitialConfigurations(for: .keyboardExtension)
        DefaultAppStatusService.shared.setHasFullAccess(hasFullAccess: self.hasFullAccess)

        logger.debug("Keyboard hasFullAccess: \(self.hasFullAccess)")

        setupLayout()
        setupBusinessLogic()

        DefaultFontsService.shared.installFonts { [weak self] in
            guard let fonttasticKeyboardView = self?.fonttasticKeyboardView else { return }
            let selectedFontModel = fonttasticKeyboardView.canvasWithSettingsView.canvasFontModel
            fonttasticKeyboardView.canvasWithSettingsView.canvasFontModel = selectedFontModel
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        DefaultFontsService.shared.storeLastUsedSettings()
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: .shouldUpdateAppStatusNotification, object: nil)
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        let isPortrait: Bool = UIScreen.main.isPortrait
        coordinator.animate { [weak self] _ in
            self?.fonttasticKeyboardView?.adaptToOrientationChange(isPortrait: isPortrait)
            self?.lockOverlayView?.adaptToOrientationChange(isPortrait: isPortrait)
        }
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        let fonttasticKeyboardView: FontasticKeyboardView
        if let keyboardView = self.fonttasticKeyboardView {
            fonttasticKeyboardView = keyboardView
        } else {
            fonttasticKeyboardView = FontasticKeyboardView(
                insertedText: [],
                initiallySelectedCanvasViewDesign: DefaultFontsService.shared.lastUsedCanvasViewDesign,
                needsNextInputKey: self.needsInputModeSwitchKey
            )
            self.fonttasticKeyboardView = fonttasticKeyboardView
        }
        if fonttasticKeyboardView.superview == nil {
            view.addSubview(fonttasticKeyboardView)
            constrain(view, fonttasticKeyboardView) { view, keyboard in
                keyboard.edges == view.edges
            }
        }

        let lockOverlayView: KeyboardLockOverlayView
        if let overlayView = self.lockOverlayView {
            lockOverlayView = overlayView
        } else {
            lockOverlayView = KeyboardLockOverlayView(
                isAdvanceToNextInputRequired: self.needsInputModeSwitchKey
            )
            self.lockOverlayView = lockOverlayView
        }
        if lockOverlayView.superview == nil {
            view.addSubview(lockOverlayView)
            constrain(view, lockOverlayView) { view, overlay in
                overlay.edges == view.edges
            }
        }
    }

    private func setupBusinessLogic() {
        if let fonttasticKeyboardView = self.fonttasticKeyboardView {
            fonttasticKeyboardView.advanceToNextInputEvent.subscribe(self) { [weak self] in
                self?.advanceToNextInputMode()
            }
            fonttasticKeyboardView.canvasWithSettingsView.shouldToggleFontSelection
                .subscribe(self) { [weak self] in
                    self?.showFontPickerViewController()
                }

            fonttasticKeyboardView.canvasWithSettingsView.shouldPresentBackgroundColorPickerEvent
                .subscribe(self) { [weak self] in
                    self?.showColorPickerViewControllerForBackgroundColor()
                }

            fonttasticKeyboardView.canvasWithSettingsView.shouldPresentBackgroundImageSelectionEvent
                .subscribe(self) { [weak self] in
                    self?.showBackgroundColorSelectionController()
                }
            fonttasticKeyboardView.canvasWithSettingsView.shouldPresentTextColorPickerEvent
                .subscribe(self) { [weak self] in
                    self?.showColorPickerViewControllerForTextColor()
                }
        }

        if let lockOverlayView = lockOverlayView {
            lockOverlayView.didTapEvent.subscribe(self) { [weak self] actionLinkURL in
                self?.openApp(url: actionLinkURL)
            }

            lockOverlayView.didTapAdvanceToNextInputButton.subscribe(self) { [weak self] in
                self?.advanceToNextInputMode()
            }
        }

        DefaultAppStatusService.shared.appStatusDidUpdateEvent.subscribe(self) { [weak self] appStatus in
            self?.handleAppStatusChange(appStatus: appStatus)
        }
    }

    // MARK: - Handling AppStatus

    private func handleAppStatusChange(appStatus: AppStatus) {
        if let lockOverlayConfig = KeyboardLockOverlayViewConfig(from: appStatus) {
            logger.debug("Will show lock overlay", description: "AppStatus: \(appStatus)")
            lockOverlayView?.isHidden = false
            lockOverlayView?.apply(config: lockOverlayConfig)
            fonttasticKeyboardView?.alpha = 0.1
        } else {
            logger.debug("Will NOT show lock overlay", description: "AppStatus: \(appStatus)")
            lockOverlayView?.isHidden = true
            fonttasticKeyboardView?.alpha = 1.0
        }
    }

    // MARK: - Opening URLs

    @objc func openURL(_ url: URL) {}

    func openApp(url: URL) {
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

    // MARK: - Presenting Font Picker

    private func showFontPickerViewController() {
        guard let fonttasticKeyboardView = self.fonttasticKeyboardView else { return }
        let fontSelectionViewController = FontSelectionController(
            initiallySelectedFontModel: fonttasticKeyboardView.canvasWithSettingsView.canvasFontModel,
            keyboardLanguage: fonttasticKeyboardView.lastUsedLanguage
        )
        fontSelectionViewController.delegate = self

        let nav = BaseNavigationController(rootViewController: fontSelectionViewController)
        present(nav, animated: true)
    }

    // MARK: - Presenting Color Picker

    private func showColorPickerViewControllerForBackgroundColor() {
        guard let fonttasticKeyboardView = self.fonttasticKeyboardView else { return }
        showColorPickerViewController(
            selectedColor: fonttasticKeyboardView.canvasWithSettingsView.canvasBackgroundColor
        ) { [weak self] color in
            self?.fonttasticKeyboardView?.canvasWithSettingsView.canvasBackgroundColor = color
        }
    }

    private func showColorPickerViewControllerForTextColor() {
        guard let fonttasticKeyboardView = self.fonttasticKeyboardView else { return }
        showColorPickerViewController(
            selectedColor: fonttasticKeyboardView.canvasWithSettingsView.canvasTextColor
        ) { [weak self] color in
            self?.fonttasticKeyboardView?.canvasWithSettingsView.canvasTextColor = color
        }
    }

    // MARK: - Presenting Image Picker

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
        guard let fonttasticKeyboardView = self.fonttasticKeyboardView else { return }
        let selectedFontModel = fonttasticKeyboardView.canvasWithSettingsView.canvasFontModel
        logger.info("Finished font selection", description: "Selected FontModel: \(selectedFontModel)")
    }

    // MARK: - Private Instance Methods

    private func setFontModelToCanvas(_ fontModel: FontModel) {
        fonttasticKeyboardView?.canvasWithSettingsView.canvasFontModel = fontModel
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
        guard let fonttasticKeyboardView = fonttasticKeyboardView else { return }

        guard let result = results.first, let assetIdentifier = result.assetIdentifier else {
            logger.debug("PhotoPicker did finish, but result is empty or has nil assetIdentifier")
            self.dismiss(animated: true)
            return
        }

        guard
            let phAsset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject
        else {
            logger.debug("PhotoPicker did finish, but unable to fetch PHAsset")
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
               targetSize: fonttasticKeyboardView.canvasWithSettingsView.targetBackgroundImageSize,
               contentMode: .aspectFill,
               options: options
        ) { [weak self] image, info in
            guard let self = self else { return }
            guard let image = image else {
                logger.debug(
                    "Failed to fetch image with PHAsset",
                    description: "Info: \(info?.debugDescription ?? "nil")"
                )
                self.dismiss(animated: true)
                return
            }
            logger.debug(
                "Did fetch image for backgroundImage",
                description: "ImageSize: \(image.size)"
            )
            self.fonttasticKeyboardView?.canvasWithSettingsView.canvasBackgroundImage = image
            self.dismiss(animated: true)
        }
    }
}

private enum Constants {

    static let openAppUrlString: String = "fonttastic://home"
}
