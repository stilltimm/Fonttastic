//
//  KeyboardInstallationState.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 19.12.2021.
//

import Foundation

public enum KeyboardInstallationState: UInt8 {

    case notInstalled
    case installedWithLimitedAccess
    case installedWithFullAccess
}
