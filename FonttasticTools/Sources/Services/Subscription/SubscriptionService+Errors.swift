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

    // MARK: - Debug Description

    public var errorCode: Int {
        switch self {
        case .noOfferingsOrError:
            return 10001

        case .noCurrentOffering:
            return 10002

        case let .purchasesError(error):
            return (error as NSError).code
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
            return (error as NSError).userInfo
        }
    }
}

public enum SubscriptionServiceError: Error {

    case serviceDeallocated
    case purchasesServiceDeallocated
    case noErrorAndPurchaserInfo
    case purchaseError(NSError, RevenueCat.ErrorCode?)
}
