//
//  FontValidator.swift
//  Fontastic
//
//  Created by Timofey Surkov on 25.09.2021.
//

import Foundation
import UIKit

final class FontModelFactory {

    // MARK: - Nested Types

    enum FontValidationError: Error {
        case notPresentInSystem
        case unregistered
    }

    // MARK: - Instance Methods

    func makeFontModels(from fontSourceModels: [FontSourceModel]) -> [FontModel] {
        return fontSourceModels.map { fontSourceModel -> FontModel in
            let fontState = makeFontState(fontSourceModel)
            return FontModel(
                name: fontSourceModel.name,
                resourceType: fontSourceModel.resourceType,
                state: fontState
            )
        }
    }

    // MARK: - Private Methods

    private func makeFontState(_ fontSourceModel: FontSourceModel) -> FontState {
        switch fontSourceModel.resourceType {
        case .system:
            return validateSystemFont(fontSourceModel)
        case .bundled:
            return validateBundledFont(fontSourceModel)
        case .userCreated:
            return validateUserCreatedFont(fontSourceModel)
        }
    }

    private func validateSystemFont(_ fontSourceModel: FontSourceModel) -> FontState {
        guard UIFont(name: fontSourceModel.name, size: Constants.defaultFontSize) != nil else {
            return .invalid(FontValidationError.notPresentInSystem)
        }

        return .ready
    }

    private func validateBundledFont(_ fontSourceModel: FontSourceModel) -> FontState {
        let isPresentInRegisterFontsList: Bool = false
        if !isPresentInRegisterFontsList {
            return .uninstalled
        }
        guard UIFont(name: fontSourceModel.name, size: Constants.defaultFontSize) != nil else {
            return .invalid(FontValidationError.notPresentInSystem)
        }

        return .ready
    }

    private func validateUserCreatedFont(_ fontSourceModel: FontSourceModel) -> FontState {
        let isPresentInRegisterFontsList: Bool = false
        if !isPresentInRegisterFontsList {
            return .uninstalled
        }
        guard UIFont(name: fontSourceModel.name, size: Constants.defaultFontSize) != nil else {
            return .invalid(FontValidationError.notPresentInSystem)
        }

        return .ready
    }
}

private enum Constants {

    static let defaultFontSize: CGFloat = 20.0
}
