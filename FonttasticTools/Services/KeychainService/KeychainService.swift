//
//  KeychainService.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 02.12.2021.
//

import Foundation

public protocol KeychainService: AnyObject {

    func makeKeychainContainer(for scope: KeychainContainerScope) -> KeychainContainer
}

public class DefaultKeychainService: KeychainService {

    // MARK: - Public Type Properties

    public static let shared = DefaultKeychainService()

    // MARK: - Initializers

    private init() {}

    // MARK: - Public Instance Methods

    public func makeKeychainContainer(for scope: KeychainContainerScope) -> KeychainContainer {
        return KeychainContainer(scope: scope)
    }
}
