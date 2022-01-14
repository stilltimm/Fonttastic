//
//  KeyboardInstallationState.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 19.12.2021.
//

import Foundation

public enum KeyboardInstallationState: String {

    case notInstalled
    case installedWithLimitedAccess
    case installedWithFullAccess

    public var description: String {
        switch self {
        case .notInstalled:
            return "🚫 Not installed"

        case .installedWithLimitedAccess:
            return "⚠️ Limited access"

        case .installedWithFullAccess:
            return "✅ Full access"
        }
    }
}
