//
//  KeychainContainerScope.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 02.12.2021.
//

import Foundation

public enum KeychainContainerScope: UInt8 {

    case app
    case keyboard
    case sharedItems

    // MARK: - Instance Properties

    var service: String {
        switch self {
        case .app:
            return Constants.appItemsKeychainService

        case .keyboard:
            return Constants.keyboardItemsKeychainService

        case .sharedItems:
            return Constants.sharedItemsKeychainService
        }
    }

    var accessGroup: String? {
        switch self {
        case .app, .keyboard:
            return nil

        case .sharedItems:
            return Constants.sharedItemsAccessGroup
        }
    }
}

private enum Constants {

    static let appItemsKeychainService = "com.romandegtyarev.fonttastic.keychain.appItems"
    static let keyboardItemsKeychainService = "com.romandegtyarev.fonttastic.keychain.keyboardItems"
    static let sharedItemsKeychainService = "com.romandegtyarev.fonttastic.keychain.sharedItems"

    static let sharedItemsAccessGroup = "group.88Q8M3ZBSJ.com.romandegtyarev.fonttastic"
}
