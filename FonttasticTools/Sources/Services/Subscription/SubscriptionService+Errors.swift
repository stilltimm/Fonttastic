//
//  SubscriptionService+Errors.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 19.12.2021.
//

import Foundation
import RevenueCat

public enum PaywallFetchError: Error, CustomNSError {

    case noOfferingsOrError
    case noCurrentOffering
    case purchasesError(Error)

    // MARK: - Public

    // MARK: - Public Instance Properties

    public var errorCode: Int {
        switch self {
        case .noOfferingsOrError:
            return 0

        case .noCurrentOffering:
            return 1

        case .purchasesError:
            return 2
        }
    }

    public var errorUserInfo: [String: Any] {
        switch self {
        case .noOfferingsOrError:
            return [
                NSLocalizedDescriptionKey: "No offerings present"
            ]

        case .noCurrentOffering:
            return [
                NSLocalizedDescriptionKey: "No current offerings"
            ]

        case let .purchasesError(error):
            return [
                NSLocalizedDescriptionKey: """
                Purchases service error [Domain: \((error as NSError).domain), code: \((error as NSError).code)]
                """,
                NSLocalizedFailureErrorKey: "Underlying error's userInfo is \((error as NSError).userInfo)",
            ]
        }
    }
}

public enum SubscriptionServiceError: Error, CustomNSError {

    case serviceDeallocated
    case purchasesServiceDeallocated
    case noErrorAndPurchaserInfo
    case purchaseError(NSError, RevenueCat.ErrorCode?)

    // MARK: - Public Type Properties

    public static var errorDomain: String { "com.romandegtyarev.fonttastic.subscription-service" }

    // MARK: - Public Instance Properties

    public var errorCode: Int {
        switch self {
        case .serviceDeallocated:
            return 0

        case .purchasesServiceDeallocated:
            return 1

        case .noErrorAndPurchaserInfo:
            return 2

        case .purchaseError:
            return 3
        }
    }

    public var errorUserInfo: [String: Any] {
        switch self {
        case .serviceDeallocated:
            return [
                NSLocalizedDescriptionKey: "Service deallocated"
            ]

        case .purchasesServiceDeallocated:
            return [
                NSLocalizedDescriptionKey: "Purchases service deallocated"
            ]

        case .noErrorAndPurchaserInfo:
            return [
                NSLocalizedDescriptionKey: "No error and purchaser info"
            ]

        case let .purchaseError(error, errorCode):
            var result: [String: Any] = [
                NSLocalizedDescriptionKey: """
                Purchases service error [Domain: \((error as NSError).domain), code: \((error as NSError).code)]
                """,
                NSLocalizedFailureErrorKey: "Underlying error's userInfo is \((error as NSError).userInfo)"
            ]
            if let errorCode = errorCode {
                result[NSHelpAnchorErrorKey] = "Normalized error code is \(errorCode)"
            }
            return result
        }
    }
}
