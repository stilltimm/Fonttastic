//
//  FontResourceType.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import Foundation

public enum FontResourceType: Equatable {

    case system
    case bundled(fileName: String)
    case userCreated

    public var isAvailableForReinstall: Bool {
        switch self {
        case .system:
            return false

        case .bundled, .userCreated:
            return true
        }
    }
}
