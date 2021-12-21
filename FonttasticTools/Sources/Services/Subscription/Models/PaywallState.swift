//
//  PaywallState.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 15.12.2021.
//

import Foundation

public enum PaywallState {

    case undefined
    case loading
    case ready(Paywall)
    case invalid(Error)

    // MARK: - Instance Properties

    public var isReady: Bool {
        switch self {
        case .ready:
            return true

        default:
            return false
        }
    }

    public var isInvalid: Bool {
        switch self {
        case .invalid:
            return true

        default:
            return false
        }
    }
}
