//
//  SubscriptionService.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 09.12.2021.
//

import Foundation
import RevenueCat
import StoreKit

public typealias PaywallItemPurchaseResult = Result<Void, SubscriptionServiceError>
public typealias PaywallItemPurchaseCompletion = (PaywallItemPurchaseResult) -> Void

public protocol SubscriptionService {

    var paywallState: PaywallState { get }
    var paywallStateDidChangeEvent: HotEvent<PaywallState> { get }

    var subscriptionState: SubscriptionState { get }
    var subscriptionStateDidChangeEvent: HotEvent<SubscriptionState> { get }

    func configurePurchases()

    func fetchPaywall(context: PaywallDidStartLoadingAnalyticsEvent.Context)

    func purchase(paywallItem: PaywallItem, completion: @escaping PaywallItemPurchaseCompletion)
    func restorePurchases(completion: @escaping PaywallItemPurchaseCompletion)
    func presentCodeRedemptionSheet()

    func fetchPurchaserInfo()

    #if DEBUG || BETA
    func overrideSubscriptionState(with subscriptionState: SubscriptionState)
    #endif
}

public final class DefaultSubscriptionService: NSObject, SubscriptionService {

    // MARK: - Nested Types

    enum PurchaserInfoUpdateContext {

        case productPurchase(PaywallItemPurchaseCompletion)
        case restorePurchases(PaywallItemPurchaseCompletion)
        case purchaserInfoUpdate
        case updateFromDelegate
        case promotedPurchase

        // MARK: - Instance Properties

        var debugDescription: String {
            switch self {
            case .productPurchase:
                return "Product Purchase"

            case .restorePurchases:
                return "Restore Purchases"

            case .purchaserInfoUpdate:
                return "PurchaserInfo Fetch"

            case .updateFromDelegate:
                return "Update from Purchases Delegate"

            case .promotedPurchase:
                return "AppStore Promoted Purchase"
            }
        }

        var completion: PaywallItemPurchaseCompletion? {
            switch self {
            case let .productPurchase(completion), let .restorePurchases(completion):
                return completion

            case .purchaserInfoUpdate, .updateFromDelegate, .promotedPurchase:
                return nil
            }
        }

        var isExpectingPurchaserInfo: Bool {
            switch self {
            case .purchaserInfoUpdate, .updateFromDelegate, .promotedPurchase:
                return true

            case .productPurchase, .restorePurchases:
                return false
            }
        }

        var isUserInitiated: Bool {
            switch self {
            case .productPurchase, .restorePurchases:
                return true

            case .purchaserInfoUpdate, .updateFromDelegate, .promotedPurchase:
                return false
            }
        }
    }

    // MARK: - Public Type Properties

    public static let shared = DefaultSubscriptionService()

    // MARK: - Public Instance Properties

    public private(set) var paywallState: PaywallState {
        didSet {
            logger.debug("PaywallState changed to \(paywallState)")
            paywallStateDidChangeEvent.onNext(paywallState)

            switch paywallState {
            case let .ready(paywall):
                analyticsService.trackEvent(PaywallLoadedAnalyticsEvent(paywall: paywall))

            case let .invalid(error):
                logger.error("Paywall Fetch Failed", error: error)

            default:
                break
            }
        }
    }
    public let paywallStateDidChangeEvent: HotEvent<PaywallState>

    public private(set) var subscriptionState: SubscriptionState {
        didSet {
            logger.debug("SubscriptionState changed to \(subscriptionState)")
            subscriptionStateDidChangeEvent.onNext(subscriptionState)
        }
    }
    public let subscriptionStateDidChangeEvent: HotEvent<SubscriptionState>

    // MARK: - Private Instance Properties

    private lazy var analyticsService: AnalyticsService = DefaultAnalyticsService.shared

    private var purchases: Purchases?

    // MARK: - Initializers

    override init() {
        let initialPaywallState: PaywallState = .loading
        self.paywallState = initialPaywallState
        self.paywallStateDidChangeEvent = HotEvent<PaywallState>(value: initialPaywallState)

        let initialSubscriptionState: SubscriptionState = .loading
        self.subscriptionState = initialSubscriptionState
        self.subscriptionStateDidChangeEvent = HotEvent<SubscriptionState>(value: initialSubscriptionState)

        super.init()
    }

    // MARK: - Public Instance Methods

    public func configurePurchases() {
        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .error
        #endif

        guard let purchasesAPIKey = AppConstants.purchasesAPIKey else {
            logger.error(
                "Failed to configure Purchases",
                description: "Purchases API Key not found"
            )
            return
        }

        let purchases = Purchases.configure(
            withAPIKey: purchasesAPIKey,
            appUserID: nil,
            observerMode: false,
            userDefaults: UserDefaults(suiteName: AppConstants.appGroupName)
        )
        self.purchases = purchases

        purchases.delegate = self
        logger.debug("Succesfully configured Purchases")
    }

    public func fetchPaywall(context: PaywallDidStartLoadingAnalyticsEvent.Context) {
        guard let purchases = purchases else { return }

        paywallState = .loading
        analyticsService.trackEvent(PaywallDidStartLoadingAnalyticsEvent(context: context))

        purchases.getOfferings { [weak self] offerings, error in
            guard let self = self else { return }

            if let error = error {
                self.paywallState = .invalid(.purchasesError(error))
                return
            }

            guard let offerings = offerings else {
                self.paywallState = .invalid(PaywallFetchError.noOfferingsOrError)
                return
            }

            guard let currentOffering = offerings.current else {
                self.paywallState = .invalid(PaywallFetchError.noCurrentOffering)
                return
            }

            let paywall = Paywall(
                offering: currentOffering,
                isTrial: currentOffering.identifier == Constants.trial3dayOfferingIdentifier
            )
            self.paywallState = .ready(paywall)
        }
    }

    public func purchase(
        paywallItem: PaywallItem,
        completion: @escaping PaywallItemPurchaseCompletion
    ) {
        guard let purchases = self.purchases else {
            completion(.failure(.purchasesServiceDeallocated))
            return
        }

        self.subscriptionState = .loading
        purchases.purchase(package: paywallItem.package) { [weak self] _, purchaserInfo, error, _ in
            guard let self = self else {
                completion(.failure(.serviceDeallocated))
                return
            }

            self.handlePurchaserInfoUpdate(
                purchaserInfo,
                error: error,
                context: .productPurchase(completion)
            )
        }
    }

    public func restorePurchases(completion: @escaping PaywallItemPurchaseCompletion) {
        guard let purchases = self.purchases else {
            completion(.failure(.purchasesServiceDeallocated))
            return
        }

        self.subscriptionState = .loading
        purchases.restoreTransactions { [weak self] purchaserInfo, error in
            guard let self = self else {
                completion(.failure(.serviceDeallocated))
                return
            }

            self.handlePurchaserInfoUpdate(
                purchaserInfo,
                error: error,
                context: .restorePurchases(completion)
            )
        }
    }

    public func presentCodeRedemptionSheet() {
        guard let purchases = purchases else { return }

        purchases.presentCodeRedemptionSheet()
    }

    public func fetchPurchaserInfo() {
        guard let purchases = purchases else { return }

        self.subscriptionState = .loading
            purchases.getCustomerInfo { [weak self] purchaserInfo, error in
            guard let self = self else { return }

            self.handlePurchaserInfoUpdate(
                purchaserInfo,
                error: error,
                context: .purchaserInfoUpdate
            )
        }
    }

    #if DEBUG || BETA
    public func overrideSubscriptionState(with subscriptionStateOverride: SubscriptionState) {
        self.subscriptionState = subscriptionStateOverride
    }
    #endif

    // MARK: - Private Instance Methods

    private func handlePurchaserInfoUpdate(
        _ purchaserInfo: RevenueCat.CustomerInfo?,
        error: Error?,
        context: PurchaserInfoUpdateContext
    ) {
        let resolvedError: SubscriptionServiceError?
        if let error = error {
            self.subscriptionState = .noSubscriptionInfo

            let nsError = error as NSError
            resolvedError = .purchaseError(nsError, error as? RevenueCat.ErrorCode)
        } else if let purchaserInfo = purchaserInfo {
            if let activeSubscriptionEntitlement = purchaserInfo.entitlements.active.values.first {
                let subscriptionInfo = SubscriptionInfo(entitlement: activeSubscriptionEntitlement)
                self.subscriptionState = .hasSubscriptionInfo(subscriptionInfo)
            } else {
                let now = Date()
                let entitlementsSortedByOriginalPurchaseDate = purchaserInfo.entitlements.all.values
                    .sorted { $1.originalPurchaseDate?.compare($0.originalPurchaseDate ?? now) == .orderedAscending }
                if let lastPurchasedEntitlement = entitlementsSortedByOriginalPurchaseDate.last {
                    let subscriptionInfo = SubscriptionInfo(entitlement: lastPurchasedEntitlement)
                    self.subscriptionState = .hasSubscriptionInfo(subscriptionInfo)
                } else {
                    self.subscriptionState = .noSubscriptionInfo
                }
            }

            resolvedError = nil
        } else {
            self.subscriptionState = .noSubscriptionInfo

            if context.isExpectingPurchaserInfo {
                resolvedError = .noErrorAndPurchaserInfo
            } else {
                // NOTE: During simple PurchaserInfo update no error and PurchaserInfo
                // means there is no info at RevenueCat and there is no active subscription
                // So it is not an error case
                resolvedError = nil
            }
        }

        if let resolvedError = resolvedError {
            logger.error("Failure during \(context.debugDescription)", error: resolvedError)
            context.completion?(.failure(resolvedError))

            if context.isUserInitiated {
                self.fetchPurchaserInfo()
            }
        } else {
            context.completion?(.success(()))
        }
    }
}

extension DefaultSubscriptionService: PurchasesDelegate {

    public func purchases(
        _ purchases: Purchases,
        receivedUpdated purchaserInfo: RevenueCat.CustomerInfo
    ) {
        self.handlePurchaserInfoUpdate(purchaserInfo, error: nil, context: .updateFromDelegate)
    }

    public func purchases(
        _ purchases: Purchases,
        shouldPurchasePromoProduct product: SKProduct,
        defermentBlock makeDeferredPurchase: @escaping DeferredPromotionalPurchaseBlock
    ) {
        let completion: PurchaseCompletedBlock = { (_, customerInfo, error, _) in
            DispatchQueue.main.async { [weak self] in
                self?.handlePurchaserInfoUpdate(customerInfo, error: error, context: .promotedPurchase)
            }
        }

        makeDeferredPurchase(completion)
    }
}

private enum Constants {

    static let trial3dayOfferingIdentifier: String = "default_with_3_days_free_trial"
}
