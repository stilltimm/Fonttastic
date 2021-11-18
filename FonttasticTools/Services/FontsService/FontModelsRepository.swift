//
//  FontModelsRepository.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import Foundation
import CoreText
import UIKit

public protocol FontModelsRepository {

    var fonts: [FontModel] { get }
    var didUpdateFontsEvent: Event<Void> { get }

    func addFont(_ fontModel: FontModel)
    func addFonts(_ fontModels: [FontModel])
}

public class DefaultFontModelsRepository: FontModelsRepository {

    // MARK: - Public Instance Properties

    public private(set) var fonts: [FontModel]
    public var didUpdateFontsEvent = Event<Void>()

    // MARK: - Private Instance Properties

    private let fontModificationsLock = NSRecursiveLock()

    // MARK: - Initializers

    public init(fonts: [FontModel]) {
        self.fonts = fonts
    }

    // MARK: - Public Instance Methods

    public func addFont(_ fontModel: FontModel) {
        fontModificationsLock.lock()
        addFontModelReplacingExisting(fontModel)
        sortFontsAndEmitUpdateEvent()
        fontModificationsLock.unlock()
    }

    public func addFonts(_ fontModels: [FontModel]) {
        fontModificationsLock.lock()
        for fontModel in fontModels {
            addFontModelReplacingExisting(fontModel)
        }

        sortFontsAndEmitUpdateEvent()
        fontModificationsLock.unlock()
    }

    // MARK: - Private Instance Methods

    private func addFontModelReplacingExisting(_ fontModel: FontModel) {
        if let index = fonts.firstIndex(where: { $0.displayName == fontModel.displayName }) {
            fonts.remove(at: index)
        }
        fonts.append(fontModel)
    }

    private func sortFontsAndEmitUpdateEvent() {
        fonts.sort { $0.name < $1.name }
        didUpdateFontsEvent.onNext(())
    }

    private func systemFonts() -> [FontSourceModel] {
        let systemFonts = UIFont.familyNames.compactMap { fontName -> FontSourceModel? in
            guard !fontName.lowercased().contains("system") else { return nil }
            return FontSourceModel(name: fontName, resourceType: .system)
        }

        return systemFonts
    }
}

private enum Constants {

    static let defaultFontSize: CGFloat = 20.0
}
