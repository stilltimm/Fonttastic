//
//  FontStatus.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 25.09.2021.
//

import Foundation

public enum FontStatus: Codable, Hashable {

    case uninstalled
    case invalid
    case ready
}
