//
//  FontValidator.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 25.09.2021.
//

import Foundation
import UIKit

public final class FontModelFactory {

    // MARK: - Nested Types

    public enum FontValidationError: Error {
        case notPresentInSystem
    }

    // MARK: - Instance Methods

    public func makeFontModels(from fontSourceModels: [FontSourceModel]) -> [FontModel] {
        return fontSourceModels.map { fontSourceModel -> FontModel in
            let fontState = makeFontState(fontSourceModel)
            return FontModel(
                name: fontSourceModel.name,
                displayName: fontSourceModel.name,
                resourceType: fontSourceModel.resourceType,
                status: fontState
            )
        }
    }

    // MARK: - Private Methods

    private func makeFontState(_ fontSourceModel: FontSourceModel) -> FontStatus {
        return validateFont(withName: fontSourceModel.name)
    }

    private func validateFont(withName fontName: String) -> FontStatus {
        guard UIFont.familyNames.contains(fontName) else {
            return .invalid(FontValidationError.notPresentInSystem as NSError)
        }

        return .ready
    }
}

private enum Constants {

    static let defaultFontSize: CGFloat = 20.0
}
