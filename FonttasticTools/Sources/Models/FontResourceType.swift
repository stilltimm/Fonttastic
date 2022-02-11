//
//  FontResourceType.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import Foundation

public enum FontResourceType: Codable, Hashable, CustomDebugStringConvertible {

    case system(fontName: String)
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

    public var isSystem: Bool {
        switch self {
        case .system:
            return true

        case .bundled, .file, .userCreated:
            return false
        }
    }

    public var typeName: String {
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

    public var debugDescription: String {
        switch self {
        case let .system(fontName):
            return "System font with name [\(fontName)]"

        case let .bundled(fileName):
            return "Bundled font with fileName [\(fileName)]"

        case let .file(fileURL):
            return "File-based font with fileURL [\(fileURL.absoluteString)]"

        case .userCreated:
            return "User Created font"
        }
    }
}
