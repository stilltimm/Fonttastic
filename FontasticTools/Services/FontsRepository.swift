//
//  FontsRepository.swift
//  Fontastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import Foundation
import CoreText
import UIKit

public protocol FontsRepository {

    var fonts: [FontModel] { get }
    var didUpdateFontsEvent: Event<Void> { get }

    func addFont(_ fontModel: FontModel)
}

public class DefaultFontsRepository: FontsRepository {

    // MARK: - Public Type Properties

    public static let shared = DefaultFontsRepository()

    // MARK: - Public Instance Properties

    public private(set) var fonts: [FontModel]
    public var didUpdateFontsEvent = Event<Void>()

    // MARK: - Private Instance Properties

    private let fontModelFactory = FontModelFactory()

    // MARK: - Initializers

    private init() {
        let systemFonts = UIFont.familyNames.compactMap { fontName -> FontSourceModel? in
            guard !fontName.lowercased().contains("system") else { return nil }
            return FontSourceModel(name: fontName, resourceType: .system)
        }
        var allPreinstalledFonts: [FontSourceModel] = [.akzidenzGroteskProBold]
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

    public func addFont(_ fontModel: FontModel) {
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
}
