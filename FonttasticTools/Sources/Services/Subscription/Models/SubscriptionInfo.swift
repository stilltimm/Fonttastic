//
//  SubscriptionInfo.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 15.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation
import RevenueCat

public struct SubscriptionInfo {

    // MARK: - Private Type Properties

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = .autoupdatingCurrent
        dateFormatter.timeZone = .autoupdatingCurrent
        return dateFormatter
    }()

    // MARK: - Public Instance Properties

    public let isActive: Bool
    public let willRenew: Bool
    public let isFamilyShared: Bool
    public let isFreeTrial: Bool
    public let originalPurchaseDate: Date?
    public let latestPurchaseDate: Date?
    public let expirationDate: Date?
}

extension SubscriptionInfo {

    // MARK: - Initializers

    init(entitlement: RevenueCat.EntitlementInfo) {
        self.isActive = entitlement.isActive
        self.willRenew = entitlement.willRenew
        self.originalPurchaseDate = entitlement.originalPurchaseDate
        self.latestPurchaseDate = entitlement.latestPurchaseDate
        self.expirationDate = entitlement.expirationDate

        switch entitlement.periodType {
        case .trial:
            self.isFreeTrial = true

        default:
            self.isFreeTrial = false
        }

        switch entitlement.ownershipType {
        case .familyShared:
            self.isFamilyShared = true

        default:
            self.isFamilyShared = false
        }
    }
}

extension SubscriptionInfo {

    public var localizedDescription: String {
        var resultString: String = ""
        if isActive {
            if isFamilyShared {
                resultString += FonttasticToolsStrings.Subscription.Info.Active.FamilyShared.title
            } else {
                resultString += FonttasticToolsStrings.Subscription.Info.Active.Solo.title
            }
            if isFreeTrial {
                if let expirationDate = expirationDate {
                    let expiraionDateString = Self.dateFormatter.string(from: expirationDate)
                    resultString += FonttasticToolsStrings.Subscription.Info.Active.FreeTrial
                        .withExpirationDate(expiraionDateString)
                } else {
                    resultString += FonttasticToolsStrings.Subscription.Info.Active.FreeTrial.withoutExpirationDate
                }
            } else {
                if let originalPurchaseDate = originalPurchaseDate {
                    let subscriptionStartDateString = Self.dateFormatter.string(from: originalPurchaseDate)
                    resultString += FonttasticToolsStrings.Subscription.Info.Active
                        .since(subscriptionStartDateString)
                }
                if let expirationDate = expirationDate {
                    let expiraionDateString = Self.dateFormatter.string(from: expirationDate)
                    if willRenew {
                        resultString += FonttasticToolsStrings.Subscription.Info.Active
                            .renewDate(expiraionDateString)
                    } else {
                        resultString += FonttasticToolsStrings.Subscription.Info.Active
                            .expirationDate(expiraionDateString)
                    }
                }
            }
        } else {
            if isFamilyShared {
                resultString += FonttasticToolsStrings.Subscription.Info.Inactive.FamilyShared.title
            } else {
                resultString += FonttasticToolsStrings.Subscription.Info.Inactive.Solo.title
            }
            if let expirationDate = expirationDate {
                let expiraionDateString = Self.dateFormatter.string(from: expirationDate)
                resultString += FonttasticToolsStrings.Subscription.Info.Inactive.TitleEnding
                    .withExpirationDate(expiraionDateString)
            } else {
                resultString += FonttasticToolsStrings.Subscription.Info.Inactive.TitleEnding.noExpirationDate
            }
            resultString += FonttasticToolsStrings.Subscription.Info.Inactive.callToAction
        }
        return resultString
    }
}

#if DEBUG || BETA
extension SubscriptionInfo {

    public static func mockActiveSubscriptionInfo() -> SubscriptionInfo {
        let now = Date()
        return SubscriptionInfo(
            isActive: true,
            willRenew: true,
            isFamilyShared: false,
            isFreeTrial: false,
            originalPurchaseDate: Calendar.current.date(
                byAdding: .day,
                value: -1,
                to: now
            ),
            latestPurchaseDate: Calendar.current.date(
                byAdding: .day,
                value: -1,
                to: now
            ),
            expirationDate: Calendar.current.date(
                byAdding: .day,
                value: 30,
                to: now
            )
        )
    }
}
#endif
