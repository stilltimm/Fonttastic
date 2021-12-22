//
//  SubscriptionViewController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 21.11.2021.
//

import UIKit
import Cartography
import FonttasticTools

class SubscriptionViewController: UIViewController, OnboardingPageViewControllerProtocol {

    // MARK: - Private Type Methods

    private static func makeDefaultActionAttributedStrings(
        text: String
    ) -> (normal: NSAttributedString, highlighted: NSAttributedString) {
        let attributedTitle = NSAttributedString(
            string: text,
            attributes: [
                .font: Constants.defaultActionFont,
                .foregroundColor: Colors.blackAndWhite
            ]
        )
        let highlightedAttributedTitle = NSAttributedString(
            string: text,
            attributes: [
                .font: Constants.defaultActionFont,
                .foregroundColor: Colors.blackAndWhite.withAlphaComponent(0.5)
            ]
        )
        return (normal: attributedTitle, highlighted: highlightedAttributedTitle)
    }

    // MARK: - Subviews / Ready State / Top Action Buttons

    private let termsActionButton: UIButton = {
        let button = UIButton()
        let (normal, highlighted) = makeDefaultActionAttributedStrings(
            text: FonttasticStrings.Localizable.Subscription.NavigationItem.termsActionTitle
        )
        button.setAttributedTitle(normal, for: .normal)
        button.setAttributedTitle(highlighted, for: .highlighted)
        return button
    }()
    private let promocodeActionButton: UIButton = {
        let button = UIButton()
        let (normal, highlighted) = makeDefaultActionAttributedStrings(
            text: FonttasticStrings.Localizable.Subscription.NavigationItem.promocodeActionTitle
        )
        button.setAttributedTitle(normal, for: .normal)
        button.setAttributedTitle(highlighted, for: .highlighted)
        return button
    }()
    private let restoreActonButton: UIButton = {
        let button = UIButton()
        let (normal, highlighted) = makeDefaultActionAttributedStrings(
            text: FonttasticStrings.Localizable.Subscription.NavigationItem.restoreActionTitle
        )
        button.setAttributedTitle(normal, for: .normal)
        button.setAttributedTitle(highlighted, for: .highlighted)
        return button
    }()

    // MARK: - Subviews / Ready State / Scroll View And Container

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.backgroundColor = .clear
        scrollView.canCancelContentTouches = true
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    // MARK: - Subviews / Ready State / Header

    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.image = UIImage(named: "keyboard-pro-header")
        return imageView
    }()
    private let headerTitle: UILabel = {
        let label = UILabel()
        label.textColor = Colors.blackAndWhite
        label.font = UIFont(name: "Futura-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    private let headerSubtitle: UILabel = {
        let label = UILabel()
        label.textColor = Colors.blackAndWhite.withAlphaComponent(0.5)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Subviews / Ready State / Pawyall Items

    private let paywallItemsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = Constants.itemSpacing
        return stackView
    }()
    private var paywallItemViews: [PaywallItemView] = []

    // MARK: - Subviews / Ready State / Purchase Action Button

    private let actionButton: GradientButton = {
        let button = GradientButton(frame: .zero)
        button.titleLabel?.font = UIFont(name: "Futura-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        button.titleLabel?.textColor = UIColor.white
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        return button
    }()
    private let actionButtonShadow = CALayer.Shadow(
        color: Colors.brandMainLight,
        alpha: 0.8,
        x: 0,
        y: 8,
        blur: 16,
        spread: -8
    )

    // MARK: - Subviews / Loading State

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Subviews / Invalid State

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Something went wrong. Please reload paywall by tapping reload button below."
        label.textColor = Colors.blackAndWhite
        label.font = UIFont(name: "AvenirNext-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    private let reloadPaywallButton: GradientButton = {
        let button = GradientButton(frame: .zero)
        button.setTitle("Reload", for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 16)
        button.titleLabel?.textColor = UIColor.white
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        return button
    }()

    // MARK: - Internal Instance Properties

    var onboardingPage: OnboardingPage { .paywall }
    let didAppearEvent = Event<OnboardingPage>()
    let didTapActionButtonEvent = Event<OnboardingPage>()

    // MARK: - Private Instance Properties

    private lazy var onboardingService: OnboardingService = DefaultOnboardingService.shared
    private lazy var subscriptionService: SubscriptionService = DefaultSubscriptionService.shared
    private var selectedPaywallItem: PaywallItem?

    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let rigidImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)

    // MARK: - Internal Instance Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true

        setupLayout()
        setupBusinessLogic()

        impactFeedbackGenerator.prepare()

        if subscriptionService.paywallState.isInvalid {
            subscriptionService.fetchPaywall()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        didAppearEvent.onNext(onboardingPage)
        impactFeedbackGenerator.impactOccurred()
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        setupNormalStateLayout()
        setupLoadingStateLayout()
        setupInvalidStateLayout()
    }

    private func setupLoadingStateLayout() {
        view.addSubview(activityIndicator)
        constrain(view, activityIndicator) { view, indicator in
            indicator.center == view.center
        }
    }

    // swiftlint:disable:next function_body_length
    private func setupNormalStateLayout() {
        if let window = UIApplication.shared.windows.first {
            scrollView.contentInset = UIEdgeInsets(
                top: window.safeAreaInsets.top,
                left: window.safeAreaInsets.left,
                bottom: window.safeAreaInsets.bottom + Constants.additionalContentInset,
                right: window.safeAreaInsets.right
            )
        }

        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(headerImageView)
        containerView.addSubview(headerTitle)
        containerView.addSubview(headerSubtitle)
        containerView.addSubview(paywallItemsStackView)
        containerView.addSubview(termsActionButton)
        containerView.addSubview(promocodeActionButton)
        containerView.addSubview(restoreActonButton)
        view.addSubview(actionButton)

        constrain(view, scrollView, containerView) { view, scrollView, container in
            scrollView.edges == view.edges
            container.width == view.width
            (container.height >= view.height).priority = .required
        }

        constrain(view, actionButton) { view, actionButton in
            actionButton.left == view.safeAreaLayoutGuide.left + Constants.edgeInsets.left
            actionButton.right == view.safeAreaLayoutGuide.right - Constants.edgeInsets.right
            actionButton.bottom == view.safeAreaLayoutGuide.bottom - Constants.edgeInsets.bottom
            actionButton.height == Constants.actionButtonHeight
        }

        constrain(
            containerView,
            headerImageView,
            headerTitle,
            headerSubtitle,
            paywallItemsStackView
        ) { container, headerImage, headerTitle, headerSubtitle, itemsStack in

            headerImage.left == container.left
            headerImage.right == container.right
            headerImage.top == container.safeAreaLayoutGuide.top
            headerImage.height == headerImage.width * Constants.headerImageAspectRatio
            headerImage.bottom == headerTitle.top

            headerTitle.left == container.safeAreaLayoutGuide.left + Constants.edgeInsets.left
            headerTitle.right == container.safeAreaLayoutGuide.right - Constants.edgeInsets.right

            headerSubtitle.left == container.safeAreaLayoutGuide.left + Constants.edgeInsets.left
            headerSubtitle.right == container.safeAreaLayoutGuide.right - Constants.edgeInsets.right
            headerSubtitle.top == headerTitle.bottom + Constants.titleToSubtitleSpacing

            itemsStack.top == headerSubtitle.bottom + Constants.subtitleToItemsSpacing
            itemsStack.bottom <= container.bottom - Constants.edgeInsets.bottom
            itemsStack.left == container.safeAreaLayoutGuide.left + Constants.edgeInsets.left
            itemsStack.right == container.safeAreaLayoutGuide.right - Constants.edgeInsets.right
        }

        constrain(
            containerView,
            termsActionButton,
            promocodeActionButton,
            restoreActonButton
        ) { container, termsButton, promocodeButton, restoreButton in

            termsButton.left == container.left + Constants.edgeInsets.left
            termsButton.top == container.top + Constants.edgeInsets.top

            restoreButton.right == container.right - Constants.edgeInsets.right
            restoreButton.top == container.top + Constants.edgeInsets.top

            promocodeButton.right == restoreButton.right
            promocodeButton.top == restoreButton.bottom + Constants.restoreToPromocodeSpacing
        }
    }

    private func setupInvalidStateLayout() {
        view.addSubview(errorLabel)
        view.addSubview(reloadPaywallButton)

        constrain(view, errorLabel, reloadPaywallButton) { view, errorLabel, reloadButton in
            errorLabel.bottom == view.centerY
            errorLabel.left == view.safeAreaLayoutGuide.left + Constants.edgeInsets.left
            errorLabel.right == view.safeAreaLayoutGuide.right - Constants.edgeInsets.right

            reloadButton.top == errorLabel.bottom + Constants.errorLabelToReloadButtonSpacing
            reloadButton.centerX == view.centerX
            reloadButton.width == view.width / 2
            reloadButton.height == Constants.actionButtonHeight
        }
    }

    // MARK: - Business Logic

    private func setupBusinessLogic() {
        termsActionButton.addTarget(self, action: #selector(self.handleTermsAction), for: .touchUpInside)
        promocodeActionButton.addTarget(self, action: #selector(self.handlePromocodeAction), for: .touchUpInside)
        restoreActonButton.addTarget(self, action: #selector(self.handleRestoreAction), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(self.handleContinueAction), for: .touchUpInside)
        reloadPaywallButton.addTarget(self, action: #selector(self.handleReloadPaywallAction), for: .touchUpInside)

        apply(paywallState: subscriptionService.paywallState)
        subscriptionService.paywallStateDidChangeEvent.subscribe(self) { [weak self] paywallState in
            self?.apply(paywallState: paywallState)
        }
    }

    private func apply(paywallState: PaywallState) {
        switch paywallState {
        case .undefined, .loading:
            scrollView.isHidden = true
            actionButton.isHidden = true
            errorLabel.isHidden = true
            reloadPaywallButton.isHidden = true
            activityIndicator.isHidden = false

            activityIndicator.startAnimating()

        case let .ready(paywall):
            apply(paywall: paywall)

            scrollView.isHidden = false
            actionButton.isHidden = false
            errorLabel.isHidden = true
            reloadPaywallButton.isHidden = true
            activityIndicator.isHidden = true

            activityIndicator.stopAnimating()

        case .invalid:
            scrollView.isHidden = true
            actionButton.isHidden = true
            errorLabel.isHidden = false
            reloadPaywallButton.isHidden = false
            activityIndicator.isHidden = true

            activityIndicator.stopAnimating()
        }
    }

    private func apply(paywall: Paywall) {
        headerTitle.text = paywall.headerTitle
        headerSubtitle.text = paywall.headerSubtitle
        actionButton.setTitle(paywall.buttonTitle, for: .normal)

        self.paywallItemsStackView.arrangedSubviews.forEach { subview in
            paywallItemsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        self.paywallItemViews = paywall.items.map(PaywallItemView.init(model:))
        self.paywallItemViews.forEach { paywallItemView in
            paywallItemsStackView.addArrangedSubview(paywallItemView)

            paywallItemView.didSelectEvent.subscribe(self) { [weak self, weak paywallItemView] in
                guard
                    let self = self,
                    let selectedModel = paywallItemView?.model
                else { return }

                self.setSelectedPaywallItem(selectedModel)
            }
        }

        selectedPaywallItem = paywall.initiallySelectedItem
        updateSelectedPaywallItemView()
    }

    private func setSelectedPaywallItem(_ item: PaywallItem) {
        impactFeedbackGenerator.impactOccurred()

        selectedPaywallItem = item
        updateSelectedPaywallItemView()
    }

    private func updateSelectedPaywallItemView() {
        paywallItemViews.forEach { itemView in
            itemView.isSelected = (itemView.model.identifier == self.selectedPaywallItem?.identifier)
        }
    }

    // MARK: - Parallax

    func handleSrollViewDidScroll(_ scrollView: UIScrollView) {
        guard
            isViewLoaded,
            let window = view.window
        else { return }

        let originInWindow = view.convert(view.frame.center, to: window)
        let windowWidth = window.bounds.width
        let percentageOffsetFromWindowCenter: CGFloat = (originInWindow.x / windowWidth) - 0.5

        let logoScale: CGFloat = 1 + (percentageOffsetFromWindowCenter * -0.2)
        headerImageView.transform = CGAffineTransform(
            translationX: percentageOffsetFromWindowCenter * -40,
            y: percentageOffsetFromWindowCenter * 40
        )
            .rotated(by: percentageOffsetFromWindowCenter * -0.1)
            .scaledBy(x: logoScale, y: logoScale)
        headerTitle.transform = CGAffineTransform(
            translationX: percentageOffsetFromWindowCenter * 40,
            y: 0
        )
        paywallItemViews.enumerated().forEach { (i, paywallItemView) in
            paywallItemView.transform = CGAffineTransform(
                translationX: percentageOffsetFromWindowCenter * (40 + (CGFloat(i) + 1) * 10),
                y: 0
            )
        }
    }

    // MARK: - Actions Handling

    @objc private func handleContinueAction() {
        rigidImpactFeedbackGenerator.impactOccurred()
        didTapActionButtonEvent.onNext(onboardingPage)

        guard let selectedPaywallItem = self.selectedPaywallItem else { return }

        logger.debug(
            "TODO: log continue paywall action",
            description: "Selected SubscriptionItem: \(selectedPaywallItem)"
        )

        self.apply(paywallState: .loading)
        subscriptionService.purchase(paywallItem: selectedPaywallItem) { [weak self] result in
            guard let self = self else { return }

            self.apply(paywallState: self.subscriptionService.paywallState)

            switch result {
            case let .failure(error):
                self.handlePurchaseError(error)

            case .success:
                self.setOnboardingCompleteIfNeeded()
                self.dismiss(animated: true)
            }
        }
    }

    @objc private func handleTermsAction() {
        impactFeedbackGenerator.impactOccurred()
        logger.debug("TODO: log terms action")

        if
            let termsURL = Constants.termsURL,
            UIApplication.shared.canOpenURL(termsURL)
        {
            UIApplication.shared.open(termsURL, options: [:])
        }
    }

    @objc private func handlePromocodeAction() {
        impactFeedbackGenerator.impactOccurred()
        logger.debug("TODO: log promocode action")

        subscriptionService.presentCodeRedemptionSheet()
    }

    @objc private func handleRestoreAction() {
        impactFeedbackGenerator.impactOccurred()
        logger.debug("TODO: log restore purchases action")

        self.apply(paywallState: .loading)
        subscriptionService.restorePurchases { [weak self] result in
            guard let self = self else { return }

            self.apply(paywallState: self.subscriptionService.paywallState)

            switch result {
            case let .failure(error):
                self.handlePurchaseError(error)

            case .success:
                self.dismiss(animated: true)
            }
        }
    }

    @objc private func handleReloadPaywallAction() {
        impactFeedbackGenerator.impactOccurred()
        logger.debug("TODO: log reload paywall action")

        subscriptionService.fetchPaywall()
    }

    @objc private func handleCloseAction() {
        self.dismiss(animated: true)
    }

    private func setOnboardingCompleteIfNeeded() {
        if !onboardingService.hasCompletedOnboarding() {
            onboardingService.setOnboardingComplete()
            logger.debug("TODO: log onboarding completion")
        }
    }

    // MARK: - Error Handling

    // swiftlint:disable:next function_body_length
    private func handlePurchaseError(_ error: SubscriptionServiceError) {
        logger.error("Purchase failed", error: error)

        let alertController: UIAlertController
        switch error {
        case let .purchaseError(nsError, errorCode):
            switch errorCode {
            case .receiptAlreadyInUseError, .productAlreadyPurchasedError:
                alertController = makeAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.alreadyPurchased
                )

            case .configurationError,
                .unexpectedBackendResponseError,
                .unknownBackendError,
                .invalidAppUserIdError,
                .invalidAppleSubscriptionKeyError,
                .invalidCredentialsError,
                .invalidReceiptError,
                .missingReceiptFileError,
                .invalidSubscriberAttributesError,
                .receiptInUseByOtherSubscriberError,
                .emptySubscriberAttributes,
                .missingAppUserIDForAliasCreationError,
                .operationAlreadyInProgressForProductError,
                .productDiscountMissingIdentifierError,
                .productDiscountMissingSubscriptionGroupIdentifierError,
                .logOutAnonymousUserError,
                .unsupportedError,
                nil:
                alertController = makeUnknownErrorAlertController()

            case .purchaseCancelledError:
                alertController = makeAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.purchaseCancelled
                )

            case .storeProblemError:
                alertController = makeAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.appStoreIsDown
                )

            case .purchaseNotAllowedError:
                alertController = makeAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.purchaseNotAllowed
                )

            case .purchaseInvalidError:
                alertController = makeAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.purchaseInvalid
                )

            case .productNotAvailableForPurchaseError:
                alertController = makeAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.productUnavailable
                )
                subscriptionService.fetchPaywall()

            case .networkError:
                alertController = makeAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.networkError
                )

            case .ineligibleError:
                alertController = makeAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.ineligibleProduct
                )
                subscriptionService.fetchPaywall()

            case .insufficientPermissionsError:
                alertController = makeAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.insufficientPermissions
                )

            case .paymentPendingError:
                alertController = makeAlertController(
                    title: FonttasticStrings.Localizable.Subscription.Error.Title.pendingPayment,
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.paymentPending
                )

            case .unknownError:
                if nsError.domain == "apple", nsError.code == 1 {
                    alertController = makeAlertController(
                        message: FonttasticStrings.Localizable.Subscription.Error.Message.alreadyPurchased
                    )
                } else {
                    alertController = makeUnknownErrorAlertController()
                }

            @unknown default:
                alertController = makeUnknownErrorAlertController()
            }

        case .serviceDeallocated, .purchasesServiceDeallocated, .noErrorAndPurchaserInfo:
            alertController = makeUnknownErrorAlertController()
        }

        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.present(alertController, animated: true)
        }
    }

    private func makeUnknownErrorAlertController() -> UIAlertController {
        return makeAlertController(message: FonttasticStrings.Localizable.Subscription.Error.Message.unknownError)
    }

    private func makeAlertController(
        title: String = FonttasticStrings.Localizable.Subscription.Error.Title.default,
        message: String
    ) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(
            title: FonttasticStrings.Localizable.Subscription.Error.OkAction.title,
            style: .default,
            handler: nil
        )
        alertController.addAction(okAction)
        return alertController
    }
}

private enum Constants {

    static let edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    static let titleToSubtitleSpacing: CGFloat = 4
    static let subtitleToItemsSpacing: CGFloat = 16
    static let itemSpacing: CGFloat = 12
    static let actionButtonHeight: CGFloat = 56

    static let errorLabelToReloadButtonSpacing: CGFloat = 16
    static let headerImageAspectRatio: CGFloat = {
        switch UIScreen.main.sizeClass {
        case .small, .normal:
            return 0.75

        default:
            return 0.85
        }
    }()

    static let defaultActionFont: UIFont = UIFont(name: "AvenirNext-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
    static let restoreToPromocodeSpacing: CGFloat = 8
    static let additionalContentInset: CGFloat = actionButtonHeight + edgeInsets.bottom + 16

    static let termsURL: URL? = URL(string: "https://google.com")
}
