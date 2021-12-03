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
    case failedToRegisterFont(errorString: String?, resourceType: FontResourceType)
    case fontAlreadyInstalled(FontResourceType)
    case missingFontName
    case networkError
    case unimplemented
}
public typealias FontInstallationResult = Result<FontModel, FontInstallationError>
public typealias FontInstallationCompletion = (FontInstallationResult) -> Void

// MARK: - FontsService

public protocol FontsService: AnyObject {

    var hasInstalledCustomFonts: Bool { get }
    var fontModelsRepository: FontModelsRepository { get }

    var lastUsedLanguage: KeyboardType.Language { get set }
    var lastUsedCanvasViewDesign: CanvasViewDesign { get set }

    func installFonts(completion: @escaping () -> Void)
    func installFont(
        from fontSourceModel: FontSourceModel,
        completion: @escaping FontInstallationCompletion
    )
    func storeLastUsedSettings()
}

public class DefaultFontsService: FontsService {

    // MARK: - Public Type Properties

    public static let shared = DefaultFontsService()

    // MARK: - Public Instance Properties

    public let fontModelsRepository: FontModelsRepository
    public private(set) var hasInstalledCustomFonts: Bool = false

    public var lastUsedCanvasViewDesign: CanvasViewDesign = .default(fontModel: Constants.defaultLastUsedFontModel)
    public var lastUsedLanguage: KeyboardType.Language = Constants.defaultLastUsedLanguage

    // MARK: - Private Instance Properties

    private let keychainService: KeychainService
    private let keychainContainer: KeychainContainer
    private lazy var fileService: FileService = DefaultFileService.shared
    private let fontModelFactory = FontModelFactory()

    // MARK: - Initializers

    private init() {
        self.fontModelsRepository = DefaultFontModelsRepository(fonts: [])
        self.keychainService = DefaultKeychainService.shared
        self.keychainContainer = keychainService.makeKeychainContainer(for: .sharedItems)

        installSystemFonts()

        if let lastUsedLanguage = restoreLastUsedLanguage() {
            self.lastUsedLanguage = lastUsedLanguage
        }
        if let cachedLastUsedCanvasViewDesign = restoreLastUsedCanvasDesign() {
            self.lastUsedCanvasViewDesign = cachedLastUsedCanvasViewDesign
        }
    }

    // MARK: - Public Instance Methods

    public func installFont(
        from fontSourceModel: FontSourceModel,
        completion: @escaping FontInstallationCompletion
    ) {
        if fontModelsRepository.fonts.contains(
            where: { $0.resourceType == fontSourceModel.resourceType && $0.status == .ready }
        ) {
            completion(.failure(.fontAlreadyInstalled(fontSourceModel.resourceType)))
            return
        }

        switch fontSourceModel.resourceType {
        case .system:
            installSystemFont(with: fontSourceModel.name, completion: completion)

        case let .bundled(fileName):
            installBundleSourcedFont(fromFile: fileName, completion: completion)

        case let .file(fileURL):
            installFileSourcedFont(fileURL: fileURL, completion: completion)

        case .userCreated:
            logger.log("Installing userCreated font in unimplemented", level: .error)
            completion(.failure(.unimplemented))
        }
    }

    public func installFonts(completion: @escaping () -> Void) {
        installCustomFonts(completion: completion)
    }

    public func storeLastUsedSettings() {
        storeLastUsedLanguage(lastUsedLanguage)
        storeLastUsedCanvasViewDesign(lastUsedCanvasViewDesign)
    }

    // MARK: - Private Instance Methods

    private func installSystemFonts() {
        let systemFontSources = self.systemFontSources()
        let systemFontModels = fontModelFactory.makeFontModels(from: systemFontSources)
        fontModelsRepository.addFonts(systemFontModels)
    }

    private func installCustomFonts(completion: @escaping () -> Void) {
        logger.log("Started installing custom fonts", level: .debug)
        let bundle = Bundle(for: Self.self)

        guard
            let customFontFileURLs = bundle.urls(
                forResourcesWithExtension: Constants.defaultFontExtension,
                subdirectory: nil
            )
        else {
            logger.log("Failed to install custom fonts - no font urls", level: .error)
            return
        }

        let dispatchGroup = DispatchGroup()
        var installedFontModels: [FontModel] = []

        for customFontFileURL in customFontFileURLs {
            dispatchGroup.enter()

            autoreleasepool { [weak self] in
                guard let self = self else {
                    return
                }
                let fontName: String = customFontFileURL.lastPathComponent
                let fontSourceModel = FontSourceModel(name: fontName, resourceType: .file(fileURL: customFontFileURL))

                self.installFont(from: fontSourceModel) { result in
                    switch result {
                    case let .failure(error):
                        logger.log(
                            "Failed to install custom font",
                            description: "Error: \(error)",
                            level: .error
                        )

                    case let .success(fontModel):
                        installedFontModels.append(fontModel)
                    }

                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            self.hasInstalledCustomFonts = true
            self.fontModelsRepository.didUpdateFontsEvent.onNext(())

            completion()
        }
    }

    // MARK: - Installing Font

    private func installSystemFont(
        with name: String,
        completion: @escaping FontInstallationCompletion
    ) {
        guard UIFont.familyNames.contains(name) else {
            completion(.failure(.notPresentInSystem))
            return
        }

        let fontModel = FontModel(name: name, displayName: name, resourceType: .system, status: .ready)
        fontModelsRepository.addFont(fontModel)

        completion(.success(fontModel))
    }

    private func installBundleSourcedFont(
        fromFile fileName: String,
        completion: @escaping FontInstallationCompletion
    ) {
        guard
            let fileUrlPath = Bundle.main.path(
                forResource: fileName,
                ofType: Constants.defaultFontExtension
            )
        else {
            let resourceName = "\(fileName).\(Constants.defaultFontExtension)"
            completion(.failure(.failedToGetFilePath(resourceName: resourceName)))
            return
        }

        let fileURL = URL(fileURLWithPath: fileUrlPath)
        installFontFromFile(
            resourceType: .bundled(fileName: fileName),
            fileURL: fileURL,
            completion: completion
        )
    }

    private func installFileSourcedFont(
        fileURL: URL,
        completion: @escaping FontInstallationCompletion
    ) {
        installFontFromFile(
            resourceType: .file(fileURL: fileURL),
            fileURL: fileURL,
            completion: completion
        )
    }

    private func installFontFromFile(
        resourceType: FontResourceType,
        fileURL: URL,
        completion: @escaping FontInstallationCompletion
    ) {
        let fontData: Data
        do {
            fontData = try Data(contentsOf: fileURL)
        } catch {
            completion(.failure(.failedToLoadFontFile(path: fileURL.path, error: error)))
            return
        }

        saveCustomFont(
            resourceType: resourceType,
            data: fontData,
            completion: completion
        )
    }

    private func saveCustomFont(
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
            complete(
                with: .failure(.failedToRegisterFont(
                    errorString: cfError?.localizedDescription,
                    resourceType: resourceType
                ))
            )
            return
        }

        guard let cfFontName = cgFont.postScriptName else {
            complete(with: .failure(.missingFontName))
            return
        }

        let fontName = String(cfFontName)
        let fontModel = FontModel(
            name: fontName,
            displayName: fontName,
            resourceType: resourceType,
            status: .ready
        )

        fontModelsRepository.addFont(fontModel)

        complete(with: .success(fontModel))
    }

    // MARK: - Utils

    private func restoreLastUsedLanguage() -> KeyboardType.Language? {
        do {
            if
                let lastUsedLanguageRawValueString = try keychainContainer.getString(
                    for: Constants.lastUsedLanguageKey
                ),
                let lastUsedLanguageRawValue = Int(lastUsedLanguageRawValueString),
                let lastUsedLanguage = KeyboardType.Language(rawValue: lastUsedLanguageRawValue)
            {
                return lastUsedLanguage
            }
        } catch {
            logger.log(
                "Error restoring last used Language",
                description: "Error: \(error)",
                level: .error
            )
        }

        return nil
    }

    private func storeLastUsedLanguage(_ language: KeyboardType.Language) {
        do {
            try keychainContainer.setString("\(language.rawValue)", for: Constants.lastUsedLanguageKey)
        } catch {
            logger.log(
                "Error storing last used Language",
                description: "Error: \(error)",
                level: .error
            )
        }
    }

    private func restoreLastUsedCanvasDesign() -> CanvasViewDesign? {
        do {
            if
                let canvasViewDesignData = try keychainContainer.getData(for: Constants.lastUsedCanvasViewDesignKey)
            {
                return try JSONDecoder().decode(CanvasViewDesign.self, from: canvasViewDesignData)
            }
        } catch {
            logger.log(
                "Error restoring last used CanvasViewDesign",
                description: "Error: \(error)",
                level: .error
            )
        }

        return nil
    }

    private func storeLastUsedCanvasViewDesign(_ canvasViewDesign: CanvasViewDesign) {
        do {
            let canvasViewDesignData = try JSONEncoder().encode(canvasViewDesign)
            try keychainContainer.setData(canvasViewDesignData, for: Constants.lastUsedCanvasViewDesignKey)
        } catch {
            logger.log(
                "Error storing last used CanvasViewDesign",
                description: "Error: \(error)",
                level: .error
            )
        }
    }

    private func systemFontSources() -> [FontSourceModel] {
        let systemFonts = UIFont.familyNames.compactMap { fontName -> FontSourceModel? in
            guard !fontName.lowercased().contains("system") else { return nil }
            return FontSourceModel(name: fontName, resourceType: .system)
        }

        return systemFonts
    }
}

private enum Constants {

    static let defaultFontExtension: String = "ttf"

    static let lastUsedLanguageKey: String = "com.romandegtyarev.Fontastic.lastUsedLanguage"
    static let lastUsedCanvasViewDesignKey: String = "com.romandegtyarev.Fontastic.lastUsedCanvasViewDesign"

    static let defaultLastUsedLanguage: KeyboardType.Language = {
        if Locale.current.identifier.lowercased().contains("ru") {
            return KeyboardType.Language.cyrillic
        }

        return KeyboardType.Language.latin
    }()

    static let defaultLastUsedFontModel: FontModel = FontModel(
        name: "Georgia-Bold",
        displayName: "Georgia Bold",
        resourceType: .system,
        status: .ready
    )
    static let defaultCanvasViewDesign: CanvasViewDesign = .default(fontModel: defaultLastUsedFontModel)
}
