//
//  FontState.swift
//  Fontastic
//
//  Created by Timofey Surkov on 25.09.2021.
//

import Foundation

enum FontState {

    case uninstalled
    case invalid(Error)
    case ready
}
