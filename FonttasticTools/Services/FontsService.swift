//
//  FontsService.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import Foundation
import CoreFoundation
import CoreText
import UIKit

// MARK: - Supporting Types

public enum FontInstallationError: Error {
    case notPresentInSystem
    case failedToGetFilePath(resourceName: String)
    case failedToLoadFontFile(path: String, error: Error)
    case failedToCreateCGDataProvider
    case failedToCreateCGFont
    case failedToRegisterFont(String?)
    case missingFontName
    case networkError
}
public typealias FontInstallationResult = Result<FontModel, FontInstallationError>
public typealias FontInstallationCompletion = (FontInstallationResult) -> Void

// MARK: - FontsService

public protocol FontsService {

    func installFont(
        from fontSourceModel: FontSourceModel,
        completion: @escaping FontInstallationCompletion
    )
}

public class DefaultFontsService: FontsService {

    // MARK: - Public Type Properties

    public static let shared = DefaultFontsService()

    // MARK: - Private Instance Properties

    private let fontsRepository: FontsRepository = DefaultFontsRepository.shared

    // MARK: - Initializers

    private init() {}

    // MARK: - Public Instance Methods

    public func installFont(
        from fontSourceModel: FontSourceModel,
        completion: @escaping FontInstallationCompletion
    ) {
        switch fontSourceModel.resourceType {
        case .system:
            installSystemFont(with: fontSourceModel.name, completion: completion)

        case let .bundled(fileName):
            installBundledFont(with: fontSourceModel.name, fromFile: fileName, completion: completion)

        case .userCreated:
            fatalError("Unimplemented")
        }
    }

    // MARK: - Private Methods

    private func installSystemFont(
        with name: String,
        completion: @escaping FontInstallationCompletion
    ) {
        guard UIFont.familyNames.contains(name) else {
            completion(.failure(.notPresentInSystem))
            return
        }

        let fontModel = FontModel(name: name, displayName: name, resourceType: .system, status: .ready)
        fontsRepository.addFont(fontModel)

        completion(.success(fontModel))
    }

    private func installBundledFont(
        with name: String,
        fromFile fileName: String,
        completion: @escaping FontInstallationCompletion
    ) {

        guard let fileUrlPath = Bundle.main.path(
                forResource: fileName,
                ofType: Constants.defaultFontExtension)
        else {
            let resourceName = "\(fileName).\(Constants.defaultFontExtension)"
            completion(.failure(.failedToGetFilePath(resourceName: resourceName)))
            return
        }

        let fontData: Data
        do {
            fontData = try Data(contentsOf: URL(fileURLWithPath: fileUrlPath))
        } catch {
            completion(.failure(.failedToLoadFontFile(path: fileUrlPath, error: error)))
            return
        }

        saveCustomFont(
            withName: name,
            resourceType: .bundled(fileName: fileName),
            data: fontData,
            completion: completion
        )
    }

    private func saveCustomFont(
        withName displayName: String,
        resourceType: FontResourceType,
        data: Data,
        completion: @escaping FontInstallationCompletion
    ) {
        func complete(with result: FontInstallationResult) {
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let nsData = NSData(data: data)
        guard let dataProvider = CGDataProvider(data: nsData) else {
            complete(with: .failure(.failedToCreateCGDataProvider))
            return
        }
        guard let cgFont = CGFont(dataProvider) else {
            complete(with: .failure(.failedToCreateCGFont))
            return
        }

        var error: Unmanaged<CFError>?
        guard CTFontManagerRegisterGraphicsFont(cgFont, &error) else {
            let cfError = error?.takeRetainedValue()
            complete(with: .failure(.failedToRegisterFont(cfError?.localizedDescription)))
            return
        }

        guard let cfFontName = cgFont.postScriptName else {
            complete(with: .failure(.missingFontName))
            return
        }

        let fontName = String(cfFontName)
        let fontModel = FontModel(
            name: fontName,
            displayName: displayName,
            resourceType: resourceType,
            status: .ready
        )

        fontsRepository.addFont(fontModel)

        complete(with: .success(fontModel))
    }
}

private enum Constants {

    static let defaultFontExtension: String = "ttf"
}
