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

    public var isInstalledWithFullAccess: Bool {
        switch self {
        case .installedWithFullAccess:
            return true

        case .installedWithLimitedAccess, .notInstalled:
            return false
        }
    }

    public var isInstalled: Bool {
        switch self {
        case .installedWithFullAccess, .installedWithLimitedAccess:
            return true

        case .notInstalled:
            return false
        }
    }
}
