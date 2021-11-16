//
//  FontStatus.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 25.09.2021.
//

import Foundation

public enum FontStatus: Hashable {

    case uninstalled
    case invalid(NSError)
    case ready
}
