//
//  SubscriptionService+Errors.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 19.12.2021.
//

import Foundation
import RevenueCat

public enum PaywallFetchError: Error {

    case noOfferingsOrError
    case noCurrentOffering
}

public enum SubscriptionServiceError: Error {

    case serviceDeallocated
    case purchasesServiceDeallocated
    case noErrorAndPurchaserInfo
    case purchaseError(NSError, RevenueCat.ErrorCode?)
}
