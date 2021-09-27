//
//  FontStatus.swift
//  Fontastic
//
//  Created by Timofey Surkov on 25.09.2021.
//

import Foundation

enum FontStatus {

    case uninstalled
    case invalid(Error)
    case ready
}
