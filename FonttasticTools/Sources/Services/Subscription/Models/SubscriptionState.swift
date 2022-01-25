//
//  SubscriptionState.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 19.12.2021.
//

import Foundation

public enum SubscriptionState {

    /// Initial status when Purchases framework is not configured yet
    case loading
    case noSubscriptionInfo
    case hasSubscriptionInfo(SubscriptionInfo)

    // MARK: - Public Instance Properties

    public var subscriptionInfo: SubscriptionInfo? {
        switch self {
        case let .hasSubscriptionInfo(info):
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

    public var isSubscriptionActive: Bool {
        switch self {
        case let .hasSubscriptionInfo(info):
            return info.isActive

        default:
            return false
        }
    }

    public var description: String {
        switch self {
        case .loading:
            return "🌎 Loading..."

        case .noSubscriptionInfo:
            return "⭕️ No subscription"

        case let .hasSubscriptionInfo(info):
            if info.isActive {
                return "✅ Active sub"
            } else {
                return "🚫 Inactive sub"
            }
        }
    }

    public var debugDescription: String {
        switch self {
        case .loading:
            return "loading"

        case .noSubscriptionInfo:
            return "noSubscriptionInfo"

        case let .hasSubscriptionInfo(info):
            if info.isActive {
                return "hasActiveSubscription"
            } else {
                return "hasInactiveSubscription"
            }
        }
    }
}
