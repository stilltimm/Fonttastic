//
//  Strings.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 21.11.2021.
//

import Foundation

class Strings {

    private static let bundle: Bundle = Bundle(for: Strings.self)

    private static func localizedString(key: String) -> String {
        return NSLocalizedString(
            key,
            tableName: nil,
            bundle: bundle,
            value: "???",
            comment: ""
        )
    }

    // MARK: - Keyboard

    static let keyboardCanvasCopiedTitle = localizedString(key: "keyboard.canvas.copied.title")

    // MARK: - Font Selection

    static let fontSelectionTitle = localizedString(key: "fontSelection.title")
    static let fontSelectionPromptLatinFonts = localizedString(key: "fontSelection.prompt.latinFonts")
    static let fontSelectionPromptCyrillicFonts = localizedString(key: "fontSelection.prompt.cyrillicFonts")

    // MARK: - Font List Collection

    static let fontListCollectionSectionHeaderSystemFonts = localizedString(
        key: "fontListCollection.sectionHeader.systemFonts"
    )
    static let fontListCollectionSectionHeaderCustomFonts = localizedString(
        key: "fontListCollection.sectionHeader.customFonts"
    )
    static let fontListCollectionKeyboardInstallBannerTitle = localizedString(
        key: "fontListCollection.keyboardInstallBanner.title"
    )
}
