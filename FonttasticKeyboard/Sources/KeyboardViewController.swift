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
import MobileCoreServices

class KeyboardViewController: UIInputViewController {

    // MARK: - Private Instance Properties

    private lazy var fontsService: FontsService = DefaultFontsService.shared
    private lazy var configurationService: ConfigurationService = DefaultConfigurationService.shared
    private lazy var appStatusService: AppStatusService = DefaultAppStatusService.shared
    private lazy var analyticsService: AnalyticsService = DefaultAnalyticsService.shared

    private var fonttasticKeyboardView: FontasticKeyboardView?
    private var lockOverlayView: KeyboardLockOverlayView?

    private var colorPickerCompletion: ((UIColor) -> Void)?
    private weak var colorPickerViewController: UIColorPickerViewController?

    private var phImageManager: PHImageManager?
    private var phAsset: PHAsset?
    private var imageRequestID: PHImageRequestID?

    // MARK: - Public Instance Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        configurationService.performInitialConfigurations(for: .keyboardExtension)
        appStatusService.setHasFullAccess(hasFullAccess: self.hasFullAccess)

        logger.debug("Keyboard hasFullAccess: \(self.hasFullAccess)")

        setupLayout()
        setupBusinessLogic()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        fontsService.storeLastUsedSettings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.post(name: .shouldUpdateAppStatusNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        analyticsService.trackEvent(KeyboardDidAppearAnalyticsEvent())
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
                initiallySelectedCanvasViewDesign: fontsService.lastUsedCanvasViewDesign,
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
                    self?.showBackgroundImageSelectionController()
                }
            fonttasticKeyboardView.canvasWithSettingsView.shouldPresentTextColorPickerEvent
                .subscribe(self) { [weak self] in
                    self?.showColorPickerViewControllerForTextColor()
                }
            fonttasticKeyboardView.canvasWithSettingsView.didChangeTextAlignmentEvent
                .subscribe(self) { [weak self] textAlignment in
                    self?.analyticsService.trackEvent(
                        KeyboardDidChangeTextAlignmentAnalyticsEvent(textAlignment: textAlignment)
                    )
                }
            fonttasticKeyboardView.canvasWithSettingsView.didCopyCanvasEvent
                .subscribe(self) { [weak self] canvasViewDesign in
                    self?.analyticsService.trackEvent(
                        KeyboardDidCopyCanvasAnalyticsEvent(canvasViewDesign: canvasViewDesign)
                    )
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

        appStatusService.appStatusDidUpdateEvent.subscribe(self) { [weak self] appStatus in
            self?.handleAppStatusChange(appStatus: appStatus)
        }
    }

    // MARK: - Handling AppStatus

    private func handleAppStatusChange(appStatus: AppStatus) {
        if let keyboardLockReason = KeyboardLockReason(appStatus: appStatus) {
            logger.debug("Will show lock overlay", description: "AppStatus: \(appStatus)")
            let lockOverlayConfig = KeyboardLockOverlayViewConfig(from: keyboardLockReason)
            lockOverlayView?.isHidden = false
            lockOverlayView?.apply(config: lockOverlayConfig)
            fonttasticKeyboardView?.alpha = 0.1

            analyticsService.trackEvent(
                KeyboardDidShowLockOverlayAnalyticsEvent(keyboardLockReason: keyboardLockReason)
            )
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
}

// MARK: - Presenting Font Picker

extension KeyboardViewController {

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
}

extension KeyboardViewController: FontSelectionControllerDelegate {

    // MARK: - Internal Instance Methods

    func didSelectFontModel(_ fontModel: FontModel) {
        setFontModelToCanvas(fontModel)

        analyticsService.trackEvent(KeyboardDidChangeFontAnalyticsEvent(fontModel: fontModel))

        self.dismiss(animated: true)
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

// MARK: - Presenting Color Picker

extension KeyboardViewController {

    private func showColorPickerViewControllerForBackgroundColor() {
        guard let fonttasticKeyboardView = self.fonttasticKeyboardView else { return }
        showColorPickerViewController(
            selectedColor: fonttasticKeyboardView.canvasWithSettingsView.canvasBackgroundColor
        ) { [weak self] color in
            guard let self = self else { return }
            self.fonttasticKeyboardView?.canvasWithSettingsView.canvasBackgroundImage = nil
            self.fonttasticKeyboardView?.canvasWithSettingsView.canvasBackgroundColor = color

            self.analyticsService.trackEvent(
                KeyboardDidChangeBackgroundColorAnalyticsEvent(colorHEX: "\(color.hexValue)")
            )
        }
    }

    private func showColorPickerViewControllerForTextColor() {
        guard let fonttasticKeyboardView = self.fonttasticKeyboardView else { return }
        showColorPickerViewController(
            selectedColor: fonttasticKeyboardView.canvasWithSettingsView.canvasTextColor
        ) { [weak self] color in
            guard let self = self else { return }
            self.fonttasticKeyboardView?.canvasWithSettingsView.canvasTextColor = color

            self.analyticsService.trackEvent(
                KeyboardDidChangeTextColorAnalyticsEvent(colorHEX: "\(color.hexValue)")
            )
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

extension KeyboardViewController: UIColorPickerViewControllerDelegate {

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        colorPickerCompletion?(viewController.selectedColor)
    }

    func colorPickerViewController(
        _ viewController: UIColorPickerViewController,
        didSelect color: UIColor,
        continuously: Bool
    ) {
        colorPickerCompletion?(viewController.selectedColor)
        colorPickerCompletion = nil
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        colorPickerCompletion = nil
    }
}

// MARK: - Presenting Image Picker

extension KeyboardViewController {

    private func showBackgroundImageSelectionController() {
        DefaultPhotosAccessService.shared.grantPhotosAccess { [weak self] accessGranted in
            guard
                accessGranted,
                let self = self
            else { return }

            self.phImageManager = PHImageManager()

            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            configuration.filter = .images
            configuration.selectionLimit = 1
            configuration.preferredAssetRepresentationMode = .compatible
            let photoPickerViewController = PHPickerViewController(configuration: configuration)
            photoPickerViewController.delegate = self

            self.present(photoPickerViewController, animated: true)
        }
    }
}

extension KeyboardViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard
            let fonttasticKeyboardView = self.fonttasticKeyboardView,
            let result = results.first
        else {
            logger.debug("PhotoPicker did finish, but result is empty")
            applyImageAndClearResources(nil)
            return
        }

        let targeSize: CGSize = fonttasticKeyboardView.canvasWithSettingsView.targetBackgroundImageSize
        if false {
            loadImageWithNSItemProvider(from: result, targetSize: targeSize) { [weak self] image, error in
                if let error = error {
                    logger.error("Failed to load item with NSItemProvider", error: error)
                }
                self?.applyImageAndClearResources(image)
            }
        } else {
            loadImageWithPHImageManager(from: result, targetSize: targeSize) { [weak self] image in
                self?.applyImageAndClearResources(image)
            }
        }
    }

    private func applyImageAndClearResources(_ image: UIImage?) {
        if let image = image {
            self.fonttasticKeyboardView?.canvasWithSettingsView.canvasBackgroundImage = image
            self.analyticsService.trackEvent(KeyboardDidSelectBackgroundImageAnaltyticsEvent())
        }

        if let imageRequestID = self.imageRequestID {
            self.phImageManager?.cancelImageRequest(imageRequestID)
        }

        self.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }

            self.phImageManager = nil
            self.phAsset = nil
            self.imageRequestID = nil
        })
    }

    // MARK: - Loading Image Implementations

    // swifltint:disable:next function_body_length
    private func loadImageWithPHImageManager(
        from pickerResult: PHPickerResult,
        targetSize: CGSize,
        _ completion: @escaping (UIImage?) -> Void
    ) {
        guard
            let assetIdentifier = pickerResult.assetIdentifier,
            let fetchedPhAsset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject
        else {
            logger.debug("PhotoPicker did finish, but unable to fetch PHAsset")
            completion(nil)
            return
        }

        self.phAsset = fetchedPhAsset

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard
                let self = self,
                let phImageManager = self.phImageManager,
                let phAsset = self.phAsset
            else {
                logger.debug("PHAsset or PHImageManager is not present")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let options = PHImageRequestOptions()
            options.version = .current
            options.isSynchronous = true
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact

            self.imageRequestID = phImageManager.requestImage(
                for: phAsset,
                   targetSize: targetSize,
                   contentMode: .aspectFill,
                   options: options
            ) { image, info in
                guard let image = image else {
                    logger.debug(
                        "Failed to fetch image with PHAsset",
                        description: "Info: \(info?.debugDescription ?? "nil")"
                    )
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                logger.debug(
                    "Did fetch image for backgroundImage",
                    description: "ImageSize: \(image.size)"
                )

                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }

    private func loadImageWithNSItemProvider(
        from pickerResult: PHPickerResult,
        targetSize: CGSize,
        _ completion: @escaping (UIImage?, Error?) -> Void
    ) {
        guard pickerResult.itemProvider.canLoadObject(ofClass: UIImage.self) else {
            completion(nil, nil)
            return
        }

        pickerResult.itemProvider.loadDataRepresentation(
            forTypeIdentifier: pickerResult.itemProvider.registeredTypeIdentifiers.first!
        ) { data, error in
            DispatchQueue.main.async {
                if let error = error {
                    logger.error("Failed to load image via ItemProvider", error: error)
                    completion(nil, error)
                    return
                }

                guard let image = data.map(UIImage.init(data:)) else {
                    completion(nil, nil)
                    return
                }

                completion(image, nil)
            }
        }
    }

    private func loadImageWithNSItemProvider2(
        from pickerResult: PHPickerResult,
        targetSize: CGSize,
        _ completion: @escaping (UIImage?, Error?) -> Void
    ) {
        guard pickerResult.itemProvider.canLoadObject(ofClass: UIImage.self) else {
            completion(nil, nil)
            return
        }

        pickerResult.itemProvider.loadDataRepresentation(
            forTypeIdentifier: pickerResult.itemProvider.registeredTypeIdentifiers.first!
        ) { data, error in
            DispatchQueue.main.async {
                if let error = error {
                    logger.error("Failed to load image via ItemProvider", error: error)
                    completion(nil, error)
                    return
                }

                guard let image = data.map(UIImage.init(data:)) else {
                    completion(nil, nil)
                    return
                }

                completion(image, nil)
            }
        }
    }
}

private enum Constants {

    static let openAppUrlString: String = "fonttastic://home"
}
