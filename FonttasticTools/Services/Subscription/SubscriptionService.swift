//
//  SubscriptionService.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 09.12.2021.
//

import Foundation
import StoreKit

public enum InAppPurchaseError: Error {

    case inAppPurchasesDisabled
    case transactionFailed(Error?)
    case cannotFindProductForTransaction

    var description: String {
        switch self {
        case .inAppPurchasesDisabled:
            return "In-App Purchases are disabled"

        case let .transactionFailed(error):
            if let error = error {
                return "Transaction failed, error: \(error.localizedDescription)"
            } else {
                return "Transaction failed, no specific error"
            }

        case .cannotFindProductForTransaction:
            return "Cannot find product for transaction"
        }
    }
}
public struct InAppPurchaseData {

    let product: SKProduct
    let transaction: SKPaymentTransaction
}
public typealias InAppPurchaseResult = Result<InAppPurchaseData, InAppPurchaseError>
public typealias InAppPurchaseCompletion = (InAppPurchaseResult) -> Void

public enum SubscriptionProduct: UInt8, CaseIterable {

    case weekly
    case monthly

    // MARK: - Type Properties

    public static let allCases: [SubscriptionProduct] = [.weekly, .monthly]

    // MARK: - Public Instance Properties

    public var inAppPurchaseID: String {
        switch self {
        case .weekly:
            return "com.romandegtyarev.fonttastic.subscription.premium.weekly"

        case .monthly:
            return "com.romandegtyarev.fonttastic.subscription.premium.monthly"
        }
    }
}

public enum ProductsFetchError: Error {

    case noProductIDsToFetch
    case invalidProductIdentifiers([String])

    var description: String {
        switch self {
        case .noProductIDsToFetch:
            return "There were no productIDs specified to fetch products"

        case let .invalidProductIdentifiers(identifiers):
            let ifentifiersString = identifiers.map { "\"\($0)\"" }.joined(separator: ", ")
            return "Products fetch failed, invalid identifiers: [\(ifentifiersString)]"
        }
    }
}

public enum SubscriptionServiceState {

    case fetching
    case hasFetchedProducts([SKProduct])
    case failedToFetchProducts(ProductsFetchError)
}

public protocol SubscriptionService {

    var state: SubscriptionServiceState { get }
    var stateDidChangeEvent: HotEvent<SubscriptionServiceState> { get }

    func fetchAvailableProducts()
    func purchase(
        product: SKProduct,
        completion: @escaping InAppPurchaseCompletion
    )
}

public final class DefaultSubscriptionService: NSObject, SubscriptionService {

    // MARK: - Nested Types

    typealias ProductsFetchData = [SKProduct]
    typealias ProductsFetchResult = Result<ProductsFetchData, ProductsFetchError>
    typealias ProductsFetchCompletion = (ProductsFetchResult) -> Void

    // MARK: - Public Type Properties

    public static let shared = DefaultSubscriptionService()

    // MARK: - Public Instance Properties

    public private(set) var state: SubscriptionServiceState {
        didSet {
            logger.log("SubscriptionState changed to \(state)", level: .debug)
            stateDidChangeEvent.onNext(state)
        }
    }
    public let stateDidChangeEvent: HotEvent<SubscriptionServiceState>

    // MARK: - Initializers

    override init() {
        let initialState: SubscriptionServiceState = .fetching
        self.state = initialState
        self.stateDidChangeEvent = HotEvent<SubscriptionServiceState>(value: initialState)

        super.init()
    }

    // MARK: - Private Instance Properties

    private var productIDs = SubscriptionProduct.allCases.map(\.inAppPurchaseID)
    private var productID = ""
    private var productsRequest = SKProductsRequest()
    private var productToPurchase: SKProduct?
    private var fetchProductCompletion: ProductsFetchCompletion?
    private var purchaseProductCompletion: InAppPurchaseCompletion?

    // MARK: - Public Instance Methods

    public func fetchAvailableProducts() {
        self.state = .fetching
        self.fetchAvailableProducts { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(products):
                self.state = .hasFetchedProducts(products)

            case let .failure(error):
                self.state = .failedToFetchProducts(error)
            }
        }
    }

    public func purchase(
        product: SKProduct,
        completion: @escaping InAppPurchaseCompletion
    ) {
        guard canMakePurchases() else {
            completion(.failure(.inAppPurchasesDisabled))
            return
        }

        purchaseProductCompletion = completion
        productToPurchase = product

        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)

        productID = product.productIdentifier
    }

    // MARK: - Private Instance Methods

    private func canMakePurchases() -> Bool {
        SKPaymentQueue.canMakePayments()
    }

    private func fetchAvailableProducts(completion: @escaping ProductsFetchCompletion) {
        guard !productIDs.isEmpty else {
            completion(.failure(.noProductIDsToFetch))
            return
        }

        fetchProductCompletion = completion

        productsRequest = SKProductsRequest(productIdentifiers: Set(productIDs))
        productsRequest.delegate = self
        productsRequest.start()
    }
}

extension DefaultSubscriptionService: SKProductsRequestDelegate, SKPaymentTransactionObserver {

    public func productsRequest(
        _ request: SKProductsRequest,
        didReceive response: SKProductsResponse
    ) {
        if !response.invalidProductIdentifiers.isEmpty {
            logger.log("\(response.invalidProductIdentifiers) identifiers are empty", level: .error)
        }

        guard let completion = fetchProductCompletion else {
            logger.log("fetchProductCompletion is nil, will not handle", level: .debug)
            return
        }

        if !response.products.isEmpty {
            completion(.success(response.products))
        } else {
            completion(.failure(.invalidProductIdentifiers(response.invalidProductIdentifiers)))
        }
    }

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .failed:
                logger.log("Product purchase failed", level: .debug)
                SKPaymentQueue.default().finishTransaction(transaction)

                if let completion = purchaseProductCompletion {
                    completion(.failure(.transactionFailed(transaction.error)))
                } else {
                    logger.log(
                        "purchaseProductCompletion is nil, will not handle purchase failure",
                        level: .debug
                    )
                }

            case .purchased:
                logger.log("Product purchased successfully", level: .debug)
                SKPaymentQueue.default().finishTransaction(transaction)

                if let completion = purchaseProductCompletion {
                    if let productToPurchase = productToPurchase {
                        let inAppPurchaseData = InAppPurchaseData(
                            product: productToPurchase,
                            transaction: transaction
                        )
                        completion(.success(inAppPurchaseData))
                    } else {
                        completion(.failure(.cannotFindProductForTransaction))
                    }
                } else {
                    logger.log(
                        "purchaseProductCompletion is nil, will not handle purchase success",
                        level: .debug
                    )
                }

            default:
                logger.log(transaction.error?.localizedDescription ?? "Something went wrong", level: .debug)
            }
        }
    }
}
