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

    // MARK: - Nested Types

    enum State {

        case loading
        case ready(Paywall, SubscriptionInfo?)
        case invalid(Error)

        init(paywallState: PaywallState, subscriptionState: SubscriptionState) {
            switch (paywallState, subscriptionState) {
            case (.loading, _), (_, .loading):
                self = .loading

            case let (.invalid(error), _):
                self = .invalid(error)

            case let (.ready(paywall), .hasSubscriptionInfo(subscriptionInfo)):
                self = .ready(paywall, subscriptionInfo)

            case let (.ready(paywall), .noSubscriptionInfo):
                self = .ready(paywall, nil)
            }
        }
    }

    // MARK: - Private Type Methods

    private static func makeActionAttributedStrings(
        text: String,
        isSecondary: Bool
    ) -> (normal: NSAttributedString, highlighted: NSAttributedString) {
        let font: UIFont = isSecondary ? Constants.smallActionFont : Constants.defaultActionFont
        let attributedTitle = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: Colors.blackAndWhite.withAlphaComponent(isSecondary ? 0.5 : 1.0)
            ]
        )
        let highlightedAttributedTitle = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: Colors.blackAndWhite.withAlphaComponent(isSecondary ? 0.25 : 0.5)
            ]
        )
        return (normal: attributedTitle, highlighted: highlightedAttributedTitle)
    }

    // MARK: - Subviews / Ready State / Action Buttons

    private let redeemCodeActionButton: UIButton = {
        let button = UIButton()
        let (normal, highlighted) = makeActionAttributedStrings(
            text: FonttasticStrings.Localizable.Subscription.Paywall.Action.redeemCode,
            isSecondary: false
        )
        button.setAttributedTitle(normal, for: .normal)
        button.setAttributedTitle(highlighted, for: .highlighted)
        return button
    }()
    private let restorePurchasesActonButton: UIButton = {
        let button = UIButton()
        let (normal, highlighted) = makeActionAttributedStrings(
            text: FonttasticStrings.Localizable.Subscription.Paywall.Action.restorePurchases,
            isSecondary: false
        )
        button.setAttributedTitle(normal, for: .normal)
        button.setAttributedTitle(highlighted, for: .highlighted)
        return button
    }()

    private let continueActionButton: GradientButton = {
        let button = GradientButton(frame: .zero)
        button.titleLabel?.font = UIFont(name: "Futura-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        button.titleLabel?.textColor = UIColor.white
        button.cornerRadius = 16
        return button
    }()
    private let actionButtonShadow = Shadow(
        color: Colors.brandMainLight,
        alpha: 0.8,
        x: 0,
        y: 8,
        blur: 16,
        spread: -8
    )

    private let termsAndPrivacyTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isSelectable = true
        textView.isEditable = false
        textView.isScrollEnabled = false

        let mutableAttributedString = NSMutableAttributedString()
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: Constants.smallActionFont,
            .foregroundColor: Colors.blackAndWhite.withAlphaComponent(0.5)
        ]
        let actionAttributes: [NSAttributedString.Key: Any] = [
            .font: Constants.smallActionFont,
            .foregroundColor: Colors.blackAndWhite
        ]
        mutableAttributedString.append(
            NSAttributedString(
                string: FonttasticStrings.Localizable.Subscription.Paywall.TermsAndPrivacy.start,
                attributes: defaultAttributes
            )
        )
        mutableAttributedString.append(
            NSAttributedString(
                string: FonttasticStrings.Localizable.Subscription.Paywall.TermsAndPrivacy.terms,
                attributes: actionAttributes.merging([.link: Constants.termsURLString]) { $1 }
            )
        )
        mutableAttributedString.append(
            NSAttributedString(
                string: FonttasticStrings.Localizable.Subscription.Paywall.TermsAndPrivacy.and,
                attributes: defaultAttributes
            )
        )
        mutableAttributedString.append(
            NSAttributedString(
                string: FonttasticStrings.Localizable.Subscription.Paywall.TermsAndPrivacy.privacyPolicy,
                attributes: actionAttributes.merging([.link: Constants.privacyPolicyURLString]) { $1 }
            )
        )

        textView.attributedText = mutableAttributedString
        textView.tintColor = Colors.blackAndWhite

        return textView
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

    // MARK: - Subviews / Loading State

    private let loadingStateOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        return view
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = UIColor.white
        return view
    }()

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
        button.cornerRadius = 16
        return button
    }()

    // MARK: - Internal Instance Properties

    var onboardingPage: OnboardingPage { .paywall }
    let didAppearEvent = Event<OnboardingPage>()
    let didTapActionButtonEvent = Event<OnboardingPage>()

    // MARK: - Private Instance Properties

    private lazy var onboardingService: OnboardingService = DefaultOnboardingService.shared
    private lazy var subscriptionService: SubscriptionService = DefaultSubscriptionService.shared
    private lazy var analyticsService: AnalyticsService = DefaultAnalyticsService.shared

    private var state: State = .loading {
        didSet {
            self.apply(state: state)
        }
    }
    private var selectedPaywallItem: PaywallItem?

    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let rigidImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)

    private var shouldPresentAlertForInactiveSubscription: Bool = false

    // MARK: - Internal Instance Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true

        setupLayout()
        setupBusinessLogic()

        impactFeedbackGenerator.prepare()

        if subscriptionService.paywallState.isInvalid {
            subscriptionService.fetchPaywall(context: .viewControllerLoaded)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        continueActionButton.applyShadow(actionButtonShadow)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        didAppearEvent.onNext(onboardingPage)
        impactFeedbackGenerator.impactOccurred()

        analyticsService.trackEvent(PaywallDidAppearAnalyticsEvent())
    }

    #if DEBUG || BETA
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)

        if motion == .motionShake {
            subscriptionService.overrideSubscriptionState(
                with: .hasSubscriptionInfo(.mockActiveSubscriptionInfo())
            )
        }
    }
    #endif

    // MARK: - Private Instance Methods

    private func setupLayout() {
        setupNormalStateLayout()
        setupInvalidStateLayout()
        setupLoadingStateLayout()
    }

    private func setupLoadingStateLayout() {
        view.addSubview(loadingStateOverlay)
        loadingStateOverlay.addSubview(activityIndicator)
        constrain(view, loadingStateOverlay, activityIndicator) { view, overlay, indicator in
            overlay.edges == view.edges
            indicator.center == overlay.center
        }

        loadingStateOverlay.isHidden = true
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
        containerView.addSubview(redeemCodeActionButton)
        containerView.addSubview(restorePurchasesActonButton)
        containerView.addSubview(headerImageView)
        containerView.addSubview(headerTitle)
        containerView.addSubview(headerSubtitle)
        containerView.addSubview(paywallItemsStackView)
        containerView.addSubview(termsAndPrivacyTextView)
        view.addSubview(continueActionButton)

        constrain(view, scrollView, containerView) { view, scrollView, container in
            scrollView.edges == view.edges
            container.width == view.width
            (container.height >= view.height).priority = .required
        }

        constrain(view, continueActionButton) { view, actionButton in
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
            redeemCodeActionButton,
            restorePurchasesActonButton
        ) { container, redeemCode, restorePurchases in
            restorePurchases.right == container.right - Constants.edgeInsets.right
            restorePurchases.top == container.top + Constants.edgeInsets.top

            redeemCode.left == container.left + Constants.edgeInsets.left
            redeemCode.top == container.top + Constants.edgeInsets.top
        }

        constrain(
            containerView, paywallItemsStackView, termsAndPrivacyTextView
        ) { container, itemsStack, termsAndPrivacyPolicy in
            termsAndPrivacyPolicy.left == container.left + Constants.edgeInsets.left
            termsAndPrivacyPolicy.right == container.right - Constants.edgeInsets.right
            termsAndPrivacyPolicy.top == itemsStack.bottom + Constants.itemsToTermsAndPrivacyPolicySpacing
        }

        scrollView.isHidden = true
        continueActionButton.isHidden = true
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

        errorLabel.isHidden = true
        reloadPaywallButton.isHidden = true
    }

    // MARK: - Business Logic

    private func setupBusinessLogic() {
        redeemCodeActionButton.addTarget(self, action: #selector(self.handlePromocodeAction), for: .touchUpInside)
        restorePurchasesActonButton.addTarget(self, action: #selector(self.handleRestoreAction), for: .touchUpInside)
        continueActionButton.addTarget(self, action: #selector(self.handleContinueAction), for: .touchUpInside)
        reloadPaywallButton.addTarget(self, action: #selector(self.handleReloadPaywallAction), for: .touchUpInside)

        termsAndPrivacyTextView.delegate = self

        apply(state: state)

        subscriptionService.paywallStateDidChangeEvent.subscribe(self) { [weak self] paywallState in
            guard let self = self else { return }
            self.state = State(
                paywallState: paywallState,
                subscriptionState: self.subscriptionService.subscriptionState
            )
        }
        subscriptionService.subscriptionStateDidChangeEvent.subscribe(self) { [weak self] subscriptionState in
            guard let self = self else { return }
            self.state = State(
                paywallState: self.subscriptionService.paywallState,
                subscriptionState: subscriptionState
            )
        }
    }

    // swiftlint:disable:next function_body_length
    private func apply(state: State) {
        switch state {
        case .loading:
            loadingStateOverlay.isHidden = false
            activityIndicator.startAnimating()

        case let .ready(paywall, subscriptionInfo):
            scrollView.isHidden = false
            continueActionButton.isHidden = false

            errorLabel.isHidden = true
            reloadPaywallButton.isHidden = true

            loadingStateOverlay.isHidden = true
            activityIndicator.stopAnimating()

            if
                let subscriptionInfo = subscriptionInfo,
                subscriptionInfo.isActive
            {
                restorePurchasesActonButton.isHidden = true
                redeemCodeActionButton.isHidden = true
                termsAndPrivacyTextView.isHidden = true

                applyActiveSubscriptionInfo()
            } else {
                restorePurchasesActonButton.isHidden = false
                redeemCodeActionButton.isHidden = false
                termsAndPrivacyTextView.isHidden = false

                applyPaywall(paywall)

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if
                        self.shouldPresentAlertForInactiveSubscription,
                        let subscriptionInfo = subscriptionInfo,
                        !subscriptionInfo.isActive
                    {
                        self.shouldPresentAlertForInactiveSubscription = false
                        let inactiveSubscriptionAlert = self.makeAlertController(
                            title: "",
                            message: subscriptionInfo.localizedDescription.unicodeScalars
                                .filter { !$0.properties.isEmojiPresentation }
                                .reduce("") { $0 + String($1) }
                        )
                        self.present(inactiveSubscriptionAlert, animated: true)
                    }
                }
            }

        case .invalid:
            scrollView.isHidden = true
            continueActionButton.isHidden = true

            errorLabel.isHidden = false
            reloadPaywallButton.isHidden = false

            loadingStateOverlay.isHidden = true
            activityIndicator.stopAnimating()
        }
    }

    private func applyPaywall(_ paywall: Paywall) {
        headerTitle.text = paywall.headerTitle
        headerSubtitle.text = paywall.headerSubtitle
        continueActionButton.setTitle(paywall.buttonTitle, for: .normal)

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

    private func applyActiveSubscriptionInfo() {
        headerTitle.text = FonttasticStrings.Localizable.Subscription.ActiveSubscription.Header.title
        headerSubtitle.text = FonttasticStrings.Localizable.Subscription.ActiveSubscription.Header.subtitle
        continueActionButton.setTitle(FonttasticStrings.Localizable.Subscription.Paywall.Action.continue, for: .normal)

        self.paywallItemsStackView.arrangedSubviews.forEach { subview in
            paywallItemsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        selectedPaywallItem = nil
    }

    private func setSelectedPaywallItem(_ item: PaywallItem) {
        impactFeedbackGenerator.impactOccurred()

        selectedPaywallItem = item
        updateSelectedPaywallItemView()

        analyticsService.trackEvent(PaywallDidChangeSelectionAnalyticsEvent(paywallItem: item))
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

        if subscriptionService.subscriptionState.isSubscriptionActive {
            self.analyticsService.trackEvent(PaywallDidFinishAnalyticsEvent())

            self.setOnboardingCompleteIfNeeded()
            self.dismiss(animated: true)
        } else {
            purchaseSelectedPaywallItem()
        }
    }

    @objc private func handlePromocodeAction() {
        impactFeedbackGenerator.impactOccurred()

        analyticsService.trackEvent(PaywallDidTapPromocodeAnalyticsEvent())
        subscriptionService.presentCodeRedemptionSheet()
    }

    @objc private func handleRestoreAction() {
        impactFeedbackGenerator.impactOccurred()

        analyticsService.trackEvent(PaywallDidTapRestoreAnalyticsEvent())
        subscriptionService.restorePurchases { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .failure(error):
                self.handlePurchaseError(error)

            case let .success(subscriptionState):
                // NOTE: successfull result does NOT guarantee active subscription
                if
                    let subscriptionInfo = subscriptionState.subscriptionInfo,
                    !subscriptionInfo.isActive
                {
                    self.shouldPresentAlertForInactiveSubscription = true
                }
            }
        }
    }

    @objc private func handleReloadPaywallAction() {
        impactFeedbackGenerator.impactOccurred()

        subscriptionService.fetchPaywall(context: .viewControllerReloadButtonTap)
    }

    // MARK: - Actions Business Logic

    private func setOnboardingCompleteIfNeeded() {
        if !onboardingService.hasCompletedOnboarding() {
            onboardingService.setOnboardingComplete()
            logger.debug("TODO: log onboarding completion")
        }
    }

    private func purchaseSelectedPaywallItem() {
        guard let selectedPaywallItem = self.selectedPaywallItem else { return }

        analyticsService.trackEvent(PaywallDidTapSubscribeAnalyticsEvent(selectedPaywallItem: selectedPaywallItem))
        subscriptionService.purchase(paywallItem: selectedPaywallItem) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .failure(error):
                // NOTE: Will log error to analytics
                logger.error("Purchase failed", error: error)
                self.handlePurchaseError(error)

            case .success:
                self.subscriptionService.fetchPurchaserInfo()
            }
        }
    }

    // MARK: - Error Handling

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    private func handlePurchaseError(_ error: SubscriptionServiceError) {
        let alertController: UIAlertController
        switch error {
        case let .purchaseError(nsError, errorCode):
            switch errorCode {
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

            case .receiptAlreadyInUseError, .productAlreadyPurchasedError:
                alertController = makeErrorAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.alreadyPurchased
                )

            case .purchaseCancelledError:
                alertController = makeErrorAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.purchaseCancelled
                )

            case .storeProblemError:
                alertController = makeErrorAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.appStoreIsDown
                )

            case .purchaseNotAllowedError:
                alertController = makeErrorAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.purchaseNotAllowed
                )

            case .purchaseInvalidError:
                alertController = makeErrorAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.purchaseInvalid
                )

            case .productNotAvailableForPurchaseError:
                alertController = makeErrorAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.productUnavailable
                )
                subscriptionService.fetchPaywall(context: .paywallItemPurchaseErrorOccured)

            case .networkError:
                alertController = makeErrorAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.networkError
                )

            case .ineligibleError:
                alertController = makeErrorAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.ineligibleProduct
                )
                subscriptionService.fetchPaywall(context: .paywallItemPurchaseErrorOccured)

            case .insufficientPermissionsError:
                alertController = makeErrorAlertController(
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.insufficientPermissions
                )

            case .paymentPendingError:
                alertController = makeErrorAlertController(
                    title: FonttasticStrings.Localizable.Subscription.Error.Title.pendingPayment,
                    message: FonttasticStrings.Localizable.Subscription.Error.Message.paymentPending
                )

            case .unknownError:
                if nsError.domain == "apple", nsError.code == 1 {
                    alertController = makeErrorAlertController(
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
    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity

    private func makeUnknownErrorAlertController() -> UIAlertController {
        return makeErrorAlertController(
            message: FonttasticStrings.Localizable.Subscription.Error.Message.unknownError
        )
    }

    private func makeErrorAlertController(
        title: String = FonttasticStrings.Localizable.Subscription.Error.Title.default,
        message: String
    ) -> UIAlertController {
        return makeAlertController(title: title, message: message)
    }

    private func makeAlertController(
        title: String,
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

extension SubscriptionViewController: UITextViewDelegate {

    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        var shouldInteract: Bool = false
        if URL.absoluteString == Constants.termsURLString {
            shouldInteract = true
            analyticsService.trackEvent(PaywallDidTapTermsAnalyticsEvent())
        } else if URL.absoluteString == Constants.privacyPolicyURLString {
            shouldInteract = true
            analyticsService.trackEvent(PaywallDidTapPrivacyPolicyAnalyticsEvent())
        }

        if shouldInteract, UIApplication.shared.canOpenURL(URL) {
            impactFeedbackGenerator.impactOccurred()
            UIApplication.shared.open(URL, options: [:])
        }

        return shouldInteract
    }
}

private enum Constants {

    static let edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    static let titleToSubtitleSpacing: CGFloat = 4
    static let subtitleToItemsSpacing: CGFloat = 16
    static let itemSpacing: CGFloat = 12
    static let itemsToTermsAndPrivacyPolicySpacing: CGFloat = 16
    static let termsToPrivacyPolicySpacing: CGFloat = 4
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
    static let smallActionFont: UIFont = UIFont(name: "AvenirNext-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12)
    static let restoreToPromocodeSpacing: CGFloat = 8
    static let additionalContentInset: CGFloat = actionButtonHeight + edgeInsets.bottom + 32

    static let termsURLString: String = "https://www.fonttastic.net/terms-conditions"
    static let termsURL: URL? = URL(string: termsURLString)
    static let privacyPolicyURLString: String = "https://www.fonttastic.net/privacy-policy"
    static let privacyPolicyURL: URL? = URL(string: privacyPolicyURLString)
}
