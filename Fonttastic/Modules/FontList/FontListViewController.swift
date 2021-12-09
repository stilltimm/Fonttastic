//
//  FontListViewController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import UIKit
import Cartography
import FonttasticTools

enum FontListError: Error {

    case failedToGrantPhotoLibraryAccess
    case noImageWasSelected

    var localizedDescription: String {
        switch self {
        case .failedToGrantPhotoLibraryAccess:
            return "Failed to access Photo Library"

        case .noImageWasSelected:
            return "No image was selected"
        }
    }
}

class FontListViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Nested Types

    enum AddFontSourceType {
        case parseFromImage
    }

    // MARK: - Subviews

    private let fontListCollectionViewController: FontListCollectionViewController

    // TODO: Show add font after solving [svg]->.ttf pipe
//    private let addFontButton = AddFontButton()

    // MARK: - Private Properties

    private let viewModel: FontListViewModel
    private let appStatusService: AppStatusService = DefaultAppStatusService.shared

    // MARK: - Initializers

    init(viewModel: FontListViewModel) {
        self.viewModel = viewModel
        self.fontListCollectionViewController = FontListCollectionViewController(
            viewModel: viewModel.fontListCollectionViewModel
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

        view.backgroundColor = Colors.backgroundMain
        navigationController?.navigationBar.isHidden = true

        setupLayout()
        setupBusinessLogic()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !appStatusService.hasCompletedOnboarding() {
            let onboardingViewController = OnboardingViewController()
            let nav = BaseNavigationController(rootViewController: onboardingViewController)
            navigationController?.present(nav, animated: true)

            logger.log("TODO: log onboarding started", level: .info)
        }
    }

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        addFontButton.layer.applyShadow(
//            color: Colors.brandMainLight,
//            alpha: 1.0,
//            x: 0,
//            y: 8,
//            blur: 16,
//            spread: -8
//        )
//    }

    // MARK: - Private Methods

    private func setupLayout() {
        setupFontListCollectionViewController()
//        setupAddFontButton()
    }

    private func setupFontListCollectionViewController() {
        addChild(fontListCollectionViewController)
        view.addSubview(fontListCollectionViewController.view)
        fontListCollectionViewController.didMove(toParent: self)

        constrain(view, fontListCollectionViewController.view) { view, fontListCollectionView in
            fontListCollectionView.edges == view.edges
        }
    }

//    private func setupAddFontButton() {
//        view.addSubview(addFontButton)
//        constrain(view, addFontButton) { view, addFontButton in
//            addFontButton.width == Constants.fontButtonSize.width
//            addFontButton.height == Constants.fontButtonSize.height
//            addFontButton.right == view.safeAreaLayoutGuide.right - Constants.fontButtonEdgeInsets.right
//            addFontButton.bottom == view.safeAreaLayoutGuide.bottom - Constants.fontButtonEdgeInsets.bottom
//        }
//    }

    private func setupBusinessLogic() {
        viewModel.fontListCollectionViewModel.didTapBannerEvent
            .subscribe(self) { [weak self] in
                guard let self = self else { return }

                let appStatus = self.appStatusService.getAppStatus(hasFullAccess: nil)
                switch (appStatus.appSubscriptionStatus, appStatus.keyboardInstallationStatus) {
                case (_, .notInstalled):
                    self.openAppSettings()

                case (.noSubscription, _):
                    self.presentSubscription()

                default:
                    break
                }
            }

        viewModel.fontListCollectionViewModel.didTapFontCell
            .subscribe(self) { [weak self] fontViewModel in
                self?.handleFontViewModelSelection(fontViewModel)
            }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        // setupAddFontButtonTapHandling()
    }

//    private func setupAddFontButtonTapHandling() {
//        addFontButton.addTarget(
//            self,
//            action: #selector(handleAddFontButtonDidTap),
//            for: .touchUpInside
//        )
//    }

    @objc private func handleAppDidBecomeActive() {
        self.viewModel.reloadData()
    }

    private func openFontDetails(_ fontModel: FontModel) {
        let fontDetailsViewController = FontDetailsViewController(fontModel: fontModel)
        let nav = BaseNavigationController(rootViewController: fontDetailsViewController)
        navigationController?.present(nav, animated: true)
    }

    private func openAppSettings() {
        guard let appSettingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

        if UIApplication.shared.canOpenURL(appSettingsUrl) {
            UIApplication.shared.open(appSettingsUrl, options: [:], completionHandler: nil)
        }
    }

    private func handleFontViewModelSelection(_ fontViewModel: FontListFontViewModel) {
        switch fontViewModel.action {
        case let .installFont(source):
            viewModel.installFont(from: source)

        case let .openDetails(fontModel):
            openFontDetails(fontModel)
        }
    }

    private func presentSubscription() {
        let subscriptionViewController = SubscriptionViewController()
        let nav = BaseNavigationController(rootViewController: subscriptionViewController)

        self.navigationController?.present(nav, animated: true)
    }

//    @objc private func handleAddFontButtonDidTap() {
//        let alertController = UIAlertController(
//            title: "Add New Font",
//            message: "Please, select how would you like to add a font",
//            preferredStyle: .actionSheet
//        )
//        let parseFromImageAlertActionHandler: (UIAlertAction) -> Void = { [weak self] _ in
//            self?.tryToPresentAddFontFlow(sourceType: .parseFromImage)
//        }
//        let customScriptTestHandler: (UIAlertAction) -> Void = { [weak self] _ in
//            self?.runCustomJavascriptCode()
//        }
//        alertController.addAction(
//            UIAlertAction(
//                title: "Parse from image",
//                style: .default,
//                handler: parseFromImageAlertActionHandler
//            )
//        )
//        alertController.addAction(
//            UIAlertAction(
//                title: "Custom Script Test",
//                style: .default,
//                handler: customScriptTestHandler
//            )
//        )
//        alertController.addAction(
//            UIAlertAction(
//                title: "Cancel",
//                style: .cancel,
//                handler: nil
//            )
//        )
//
//        navigationController?.present(alertController, animated: true)
//    }

//    private func tryToPresentAddFontFlow(sourceType: AddFontSourceType) {
//        switch sourceType {
//        case .parseFromImage:
//            PhotosAccessService.shared.grantPhotosAccess { [weak self] isGranted in
//                if isGranted {
//                    self?.presentPhotosPickerController()
//                } else {
//                    self?.presentErrorAlert(.failedToGrantPhotoLibraryAccess)
//                }
//            }
//        }
//    }

//    private func presentPhotosPickerController() {
//        let imagePickerViewController = UIImagePickerController()
//        imagePickerViewController.sourceType = .photoLibrary
//        imagePickerViewController.delegate = self
//
//        navigationController?.present(imagePickerViewController, animated: true)
//    }

//    private func presentAddFontFlow(with context: AddFontNavigationController.Context) {
//        let addFontNavigationController = AddFontNavigationController(context: context)
//        navigationController?.present(addFontNavigationController, animated: true)
//    }
//
//    private func runCustomJavascriptCode() {
//        let svg2ttfJavaScriptRunner = SVG2TTFJavaScriptRunner()
//        svg2ttfJavaScriptRunner.run(inputs: ["A", "B", "C"])
//    }

    // MARK: - Errors Handling

//    private func presentErrorAlert(_ error: FontListError) {
//        let alertController = UIAlertController(
//            title: "Ooops.. Error occured :(",
//            message: error.localizedDescription,
//            preferredStyle: .actionSheet
//        )
//
//        switch error {
//        case .failedToGrantPhotoLibraryAccess:
//            let openSettingsAlertActionHandler: (UIAlertAction) -> Void = { [weak self] _ in
//                self?.openAppSettings()
//            }
//            alertController.addAction(
//                UIAlertAction(
//                    title: "Go to app settings",
//                    style: .default,
//                    handler: openSettingsAlertActionHandler
//                )
//            )
//
//        default:
//            break
//        }
//
//        alertController.addAction(
//            UIAlertAction(
//                title: "Close",
//                style: .cancel,
//                handler: nil
//            )
//        )
//
//        navigationController?.present(alertController, animated: true)
//    }
}

// extension FontListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    func imagePickerController(
//        _ picker: UIImagePickerController,
//        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
//    ) {
//        logger.log("Finished picking media type with info \(info)", level: .debug)

//        guard let image = info[.originalImage] as? UIImage else {
//            self.dismiss(animated: true) { [weak self] in
//                self?.presentErrorAlert(.noImageWasSelected)
//            }
//            return
//        }

//        self.dismiss(animated: true) { [weak self] in
//            self?.presentAddFontFlow(with: .init(sourceType: .parseFromImage(image)))
//        }
//    }

//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        self.dismiss(animated: true)
//    }
// }

private enum Constants {

    static let spacing: CGFloat = 16.0
    static let title = "Fonttastic"

//    static let fontButtonSize: CGSize = .init(width: 64, height: 64)
//    static let fontButtonEdgeInsets: UIEdgeInsets = .init(vertical: 16.0, horizontal: 16.0)
}
