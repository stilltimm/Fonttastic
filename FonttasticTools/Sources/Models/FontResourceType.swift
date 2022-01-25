//
//  FontResourceType.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import Foundation

public enum FontResourceType: Codable, Hashable {

    case system
    case bundled(fileName: String)
    case file(fileURL: URL)
    case userCreated

    public var isAvailableForReinstall: Bool {
        switch self {
        case .system:
            return false

        case .bundled, .file, .userCreated:
            return true
        }
    }

    public var description: String {
        switch self {
        case .system:
            return "system"

        case .bundled:
            return "bundled"

        case .file:
            return "file"

        case .userCreated:
            return "userCreated"
        }
    }
}
