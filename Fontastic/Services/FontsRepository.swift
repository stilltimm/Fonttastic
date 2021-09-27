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
    var didUpdateFontsEvent: Event<Void> { get }

    func addFont(_ fontModel: FontModel)
}

class DefaultFontsRepository: FontsRepository {

    // MARK: - Public Type Properties

    static let shared = DefaultFontsRepository()

    // MARK: - Public Instance Properties

    private(set) var fonts: [FontModel]
    var didUpdateFontsEvent = Event<Void>()

    // MARK: - Private Instance Properties

    private let fontModelFactory = FontModelFactory()

    // MARK: - Initializers

    private init() {
        let systemFonts = UIFont.familyNames.map { fontName -> FontSourceModel in
            FontSourceModel(name: fontName, resourceType: .system)
        }
        var allPreinstalledFonts = Constants.preinstalledFontModels
        allPreinstalledFonts.append(contentsOf: systemFonts)
        let preinstalledFonts = fontModelFactory.makeFontModels(from: allPreinstalledFonts)

        self.fonts = preinstalledFonts.filter { fontModel -> Bool in
            switch fontModel.status {
            case let .invalid(error):
                print("DefaultFontsRepository: At startup font \(fontModel) got invalid status with error \(error)")
                return fontModel.resourceType.isAvailableForReinstall

            default:
                return true
            }
        }.sorted { $0.name < $1.name }
    }

    // MARK: - Instance Methods

    func addFont(_ fontModel: FontModel) {
        if let index = fonts.firstIndex(where: { $0.displayName == fontModel.displayName }) {
            fonts.remove(at: index)
        }

        fonts.append(fontModel)
        fonts.sort { $0.name < $1.name }

        didUpdateFontsEvent.onNext(())
    }
}

private enum Constants {

    static let defaultFontSize: CGFloat = 20.0

    // MARK: - Test data

    static let preinstalledFontModels: [FontSourceModel] = [
        .init(
            name: "Akzindenz Grotesk Pro Bold",
            resourceType: .bundled(fileName: "akzidenzgroteskpro-bold")
        )
    ]
}
