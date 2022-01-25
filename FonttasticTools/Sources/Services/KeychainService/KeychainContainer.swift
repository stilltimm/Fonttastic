//
//  KeychainContainer.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 02.12.2021.
//

import Foundation
import KeychainAccess

public class KeychainContainer {

    // MARK: - Private Instance Properties

    private let keychain: Keychain

    // MARK: - Initializers

    convenience init(scope: KeychainContainerScope) {
        self.init(service: scope.service, accessGroup: scope.accessGroup)
    }

    private init(service: String, accessGroup: String?) {
        if let accessGroup = accessGroup {
            self.keychain = Keychain(service: service, accessGroup: accessGroup)
        } else {
            self.keychain = Keychain(service: service)
        }
    }

    // MARK: - Public Instance Methods

    public func getData(for key: String) throws -> Data? {
        return try keychain.getData(key)
    }

    public func setData(_ data: Data, for key: String) throws {
        try keychain.set(data, key: key)
    }

    public func getString(for key: String) throws -> String? {
        return try keychain.getString(key)
    }

    public func setString(_ string: String, for key: String) throws {
        try keychain.set(string, key: key)
    }

    public func removeItem(for key: String) throws {
        try keychain.remove(key)
    }
}
