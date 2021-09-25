//
//  FontsRepository.swift
//  Fontastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import Foundation
import CoreText
import UIKit

protocol FontsRepository {

    var fonts: [FontModel] { get }
}

class DefaultFontsRepository: FontsRepository {

    let fonts: [FontModel]

    // MARK: - Private Properties

    private let fontModelFactory = FontModelFactory()

    init() {
        let preinstalledFonts = fontModelFactory.makeFontModels(from: Constants.preinstalledFontModels)

        self.fonts = preinstalledFonts.filter { fontModel -> Bool in
            switch fontModel.state {
            case let .invalid(error):
                print("DefaultFontsRepository: At startup font \(fontModel) got invalid state with error \(error)")
                return fontModel.resourceType.isAvailableForReinstall

            default:
                return true
            }
        }
    }

    // MARK: - Font Validation
}

private enum Constants {

    static let defaultFontSize: CGFloat = 20.0

    // MARK: - Test data

    static let preinstalledFontModels: [FontSourceModel] = [
        .init(
            name: "Akzindenz Grotesk Pro Bold",
            resourceType: .bundled(fileName: "akzidenzgroteskpro-bold")
        ),
        .init(name: "Helvetica Neue", resourceType: .system),
        .init(name: "Avenir Next", resourceType: .system),
        .init(name: "Times New Roman", resourceType: .system),
    ]
}
