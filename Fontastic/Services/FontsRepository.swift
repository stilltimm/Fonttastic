//
//  FontsRepository.swift
//  Fontastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import Foundation

protocol FontsRepository {

    var fonts: [FontModel] { get }
}

class DefaultFontsRepository: FontsRepository {

    let fonts: [FontModel] = [
        "Helvetica Neue",
        "Avenir Next",
        "Bebase Neue",
        "Times New Roman",
        "Comic Sans",
        "Raleway",
        "Roboto",
        "Futura",
        "Open Sans",
        "Montserrat"
    ]
    .sorted()
    .map { FontModel(name: $0, type: .downloaded) }
}
