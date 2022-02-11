//
//  PaywallState.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 15.12.2021.
//

import Foundation

public enum PaywallState {

    case loading
    case ready(Paywall)
    case invalid(PaywallFetchError)

    // MARK: - Instance Properties

    public var isInvalid: Bool {
        switch self {
        case .invalid:
            return true

        default:
            return false
        }
    }
}
