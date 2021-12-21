//
//  PurchasesPackageType+Extensions.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 15.12.2021.
//

import Foundation
import RevenueCat

extension RevenueCat.PackageType {

    var displayPriority: Int {
        switch self {
        case .weekly:
            return 0

        case .monthly:
            return 1

        case .twoMonth:
            return 2

        case .threeMonth:
            return 3

        case .sixMonth:
            return 4

        case .annual:
            return 5

        case .lifetime:
            return 6

        case .custom:
            return 7

        case .unknown:
            return 8

        @unknown default:
            return 9
        }
    }

    var localizedDescription: String {
        switch self {
        case .weekly:
            return FonttasticToolsStrings.Subscription.Period.weekly

        case .monthly:
            return FonttasticToolsStrings.Subscription.Period.monthly

        case .twoMonth:
            return FonttasticToolsStrings.Subscription.Period.twoMonths

        case .threeMonth:
            return FonttasticToolsStrings.Subscription.Period.threeMonths

        case .sixMonth:
            return FonttasticToolsStrings.Subscription.Period.sixMonths

        case .annual:
            return FonttasticToolsStrings.Subscription.Period.annual

        case .lifetime:
            return FonttasticToolsStrings.Subscription.Period.lifetime

        case .custom, .unknown:
            return Constants.unknownPackageTypeDescription

        @unknown default:
            return Constants.unknownPackageTypeDescription
        }
    }
}

private enum Constants {

    static let unknownPackageTypeDescription: String = "???"
}
