//
//  KeyboardViewTestController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import Cartography
import FonttasticTools
import Photos
import PhotosUI

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
    private let lockOverlayView: KeyboardLockOverlayView = KeyboardLockOverlayView()

    // MARK: - Private Instance Properties

    private let fontsService: FontsService = DefaultFontsService.shared
    private let phImageManager = PHImageManager()

    // MARK: - Initializers

    init() {
        self.fontasticKeyboardView = FontasticKeyboardView(
            insertedText: "Test string".map { String($0) },
            initiallySelectedCanvasViewDesign: fontsService.lastUsedCanvasViewDesign
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
        fontasticKeyboardView.alpha = 0.25

        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.backgroundColor = Colors.backgroundMain

        containerView.addSubview(fontasticKeyboardView)
        containerView.addSubview(lockOverlayView)
        constrain(
            view, scrollView, containerView, fontasticKeyboardView, lockOverlayView
        ) { (view, scrollView, container, keyboard, overlay) in
            scrollView.edges == view.edges

            (container.width == view.width).priority = .required
            container.height == UIScreen.main.bounds.height

            keyboard.center == container.center
            keyboard.width == container.width

            overlay.edges == keyboard.edges
        }
    }

    private func setupBusinessLogic() {
        fontasticKeyboardView.canvasWithSettingsView.shouldToggleFontSelection.subscribe(self) { [weak self] in
            self?.presentFontPickerViewController()
        }
        fontasticKeyboardView.canvasWithSettingsView.shouldPresentBackgroundImageSelectionEvent
            .subscribe(self) { [weak self] in
                self?.presentBackgroundColorSelectionController()
            }
    }

    private func presentFontPickerViewController() {
        let fontSelectionViewController = FontSelectionController(
            initiallySelectedFontModel: fontasticKeyboardView.canvasWithSettingsView.canvasFontModel,
            keyboardLanguage: fontasticKeyboardView.lastUsedLanguage
        )
        fontSelectionViewController.delegate = self
        let nav = BaseNavigationController(rootViewController: fontSelectionViewController)
        present(nav, animated: true)
    }

    private func presentBackgroundColorSelectionController() {
        DefaultPhotosAccessService.shared.grantPhotosAccess { [weak self] accessGranted in
            guard let self = self else { return }
            guard accessGranted else {
                self.presentPhotosAccesAlert()
                return
            }

            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            configuration.filter = .images
            configuration.selectionLimit = 1
            let photoPickerViewController = PHPickerViewController(configuration: configuration)
            photoPickerViewController.delegate = self

            self.navigationController?.present(photoPickerViewController, animated: true)
        }
    }

    private func presentPhotosAccesAlert() {
        let alertController = UIAlertController(
            title: "Cannot access Photos",
            message: "Please give Fonttastic access to Ph",
            preferredStyle: .actionSheet
        )
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        navigationController?.present(alertController, animated: true)
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
    }
}

extension KeyboardViewTestViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let result = results.first, let assetIdentifier = result.assetIdentifier else {
            logger.log("PhotoPicker did finish, but result is empty or has nil assetIdentifier", level: .debug)
            return
        }

        guard
            let phAsset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject
        else {
            logger.log("PhotoPicker did finish, but unable to fetch PHAsset", level: .debug)
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
            guard let image = image else {
                logger.log(
                    "Failed to fetch image with PHAsset",
                    description: "Info: \(info?.debugDescription ?? "nil")",
                    level: .debug
                )
                return
            }
            logger.log(
                "Did fetch image for backgroundImage",
                description: "ImageSize: \(image.size)",
                level: .debug
            )
            self?.fontasticKeyboardView.canvasWithSettingsView.canvasBackgroundImage = image
            self?.navigationController?.dismiss(animated: true)
        }
    }
}
