//
//  FontSymbolSourceModel.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 09.11.2021.
//

import Foundation

public enum FontSymbolSourceModel {
    case symbol(String)
    case capitalizableSymbol(lowercase: String, uppercase: String)
}
