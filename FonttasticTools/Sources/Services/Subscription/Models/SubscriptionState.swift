//
//  SubscriptionState.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 19.12.2021.
//

import Foundation
import RevenueCat

public enum SubscriptionState {

    /// Initial status when Purchases framework is not configured yet
    case loading
    case noSubscription
    case hasInactiveSubscription(SubscriptionInfo)
    case hasActiveSubscription(SubscriptionInfo)

    // MARK: - Public Instance Properties

    public var subscriptionInfo: SubscriptionInfo? {
        switch self {
        case let .hasInactiveSubscription(info), let .hasActiveSubscription(info):
            return info

        default:
            return nil
        }
    }

    public var isLoading: Bool {
        switch self {
        case .loading:
            return true

        default:
            return false
        }
    }

    public var description: String {
        switch self {
        case .loading:
            return "🌎 Loading..."

        case .noSubscription:
            return "⭕️ No subscription"

        case .hasInactiveSubscription:
            return "🚫 Inactive sub"

        case .hasActiveSubscription:
            return "✅ Active sub"
        }
    }
}

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
