//
//  Strings.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 21.11.2021.
//

import Foundation

public class LocalizedStringsBox {

    // MARK: - Private Instance Properties

    private let bundle: Bundle

    // MARK: - Initializers

    public init(bundle: Bundle) {
        self.bundle = bundle
    }

    // MARK: - Public Instance Methods

    public func localizedString(for key: String) -> String {
        return NSLocalizedString(
            key,
            tableName: nil,
            bundle: bundle,
            value: "???",
            comment: ""
        )
    }

    public subscript(_ key: String) -> String {
        localizedString(for: key)
    }
}

class Strings {

    // MARK: - Private Type Properties

    private static let localizedStringBox = LocalizedStringsBox(bundle: Bundle(for: Strings.self))

    // MARK: - Keyboard

    static let keyboardCanvasCopiedTitle = localizedStringBox["keyboard.canvas.copied.title"]

    // MARK: - Font Selection

    static let fontSelectionTitle = localizedStringBox["fontSelection.title"]
    static let fontSelectionPromptLatinFonts = localizedStringBox["fontSelection.prompt.latinFonts"]
    static let fontSelectionPromptCyrillicFonts = localizedStringBox["fontSelection.prompt.cyrillicFonts"]

    // MARK: - Font List Collection

    static let fontListCollectionSectionHeaderSystemFonts = localizedStringBox[
        "fontListCollection.sectionHeader.systemFonts"
    ]
    static let fontListCollectionSectionHeaderCustomFonts = localizedStringBox[
        "fontListCollection.sectionHeader.customFonts"
    ]
    static let fontListCollectionKeyboardInstallBannerTitle = localizedStringBox[
        "fontListCollection.keyboardInstallBanner.title"
    ]
}
