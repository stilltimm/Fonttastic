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

public enum FontInstallationError: Error, CustomNSError {

    case notPresentInSystem(fontName: String)
    case failedToGetFilePath(resourceName: String)
    case failedToLoadFontFile(path: String, error: Error)
    case failedToCreateCGDataProvider(FontResourceType)
    case failedToCreateCGFont(FontResourceType)
    case failedToRegisterFont(errorString: String?, resourceType: FontResourceType)
    case fontAlreadyInstalled(FontResourceType)
    case missingFontName(FontResourceType)
    case unimplemented(FontResourceType)

    // MARK: - Public Type Properties

    public static var errorDomain: String { "com.romandegtyarev.fonttastic.font-installation" }

    // MARK: - Public Instance Properties

    public var errorCode: Int {
        switch self {
        case .notPresentInSystem:
            return 0

        case .failedToGetFilePath:
            return 1

        case .failedToLoadFontFile:
            return 2

        case .failedToCreateCGDataProvider:
            return 3

        case .failedToCreateCGFont:
            return 4

        case .failedToRegisterFont:
            return 5

        case .fontAlreadyInstalled:
            return 6

        case .missingFontName:
            return 7

        case .unimplemented:
            return 8
        }
    }

    public var errorUserInfo: [String: Any] {
        switch self {
        case let .notPresentInSystem(fontName):
            return [
                NSLocalizedDescriptionKey: "Font not present in system",
                NSHelpAnchorErrorKey: "Font name is [\(fontName)]"
            ]

        case let .failedToGetFilePath(resourceName):
            return [
                NSLocalizedDescriptionKey: "Failed to get file path for resource name",
                NSHelpAnchorErrorKey: "Resource name is [\(resourceName)]"
            ]

        case let .failedToLoadFontFile(path, error):
            return [
                NSLocalizedDescriptionKey: "Failed to load file path for resource name",
                NSLocalizedFailureReasonErrorKey: (error as NSError).userInfo,
                NSHelpAnchorErrorKey: "Path is [\(path)]",
            ]

        case let .failedToCreateCGDataProvider(resourceType):
            return [
                NSLocalizedDescriptionKey: "Failed to create CGDataProvider",
                NSHelpAnchorErrorKey: "FontResourceType is [\(resourceType.debugDescription)]"
            ]

        case let .failedToCreateCGFont(resourceType):
            return [
                NSLocalizedDescriptionKey: "Failed to create CGFont",
                NSHelpAnchorErrorKey: "FontResourceType is [\(resourceType.debugDescription)]"
            ]

        case let .failedToRegisterFont(errorString, resourceType):
            var result: [String: Any] = [
                NSLocalizedDescriptionKey: "Failed to load file path for resource name",
                NSHelpAnchorErrorKey: "FontResourceType is [\(resourceType.debugDescription)]"
            ]
            if let errorString = errorString {
                result[NSLocalizedFailureReasonErrorKey] = errorString
            }
            return result

        case let .fontAlreadyInstalled(resourceType):
            return [
                NSLocalizedDescriptionKey: "Font already installed",
                NSHelpAnchorErrorKey: "FontResourceType is [\(resourceType.debugDescription)]"
            ]

        case let .missingFontName(resourceType):
            return [
                NSLocalizedDescriptionKey: "Missing font name",
                NSHelpAnchorErrorKey: "FontResourceType is [\(resourceType.debugDescription)]"
            ]

        case let .unimplemented(resourceType):
            return [
                NSLocalizedDescriptionKey: "Font installation of such type is unimplemented",
                NSHelpAnchorErrorKey: "FontResourceType is [\(resourceType.debugDescription)]"
            ]
        }
    }
}
public typealias FontInstallationResult = Result<FontModel, FontInstallationError>
public typealias FontInstallationCompletion = (FontInstallationResult) -> Void

// MARK: - FontsService

public protocol FontsService: AnyObject {

    var hasInstalledCustomFonts: Bool { get }
    var fontModelsRepository: FontModelsRepository { get }

    var lastUsedLanguage: KeyboardType.Language { get set }
    var lastUsedCanvasViewDesign: CanvasViewDesign { get set }

    func installFonts(completion: (() -> Void)?)
    func installFont(
        from fontSourceModel: FontSourceModel,
        completion: @escaping FontInstallationCompletion
    )
    func storeLastUsedSettings()
    func resetStoredSettings()
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
    private lazy var analyticsService: AnalyticsService = DefaultAnalyticsService.shared

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
            logger.debug("Installing userCreated font in unimplemented")
            completion(.failure(.unimplemented(fontSourceModel.resourceType)))
        }
    }

    public func installFonts(completion: (() -> Void)?) {
        installCustomFonts(completion: completion)
    }

    public func storeLastUsedSettings() {
        storeLastUsedLanguage(lastUsedLanguage)
        storeLastUsedCanvasViewDesign(lastUsedCanvasViewDesign)
    }

    public func resetStoredSettings() {
        storeLastUsedLanguage(Constants.defaultLastUsedLanguage)
        storeLastUsedCanvasViewDesign(.default(fontModel: Constants.defaultLastUsedFontModel))
    }

    // MARK: - Private Instance Methods

    private func installSystemFonts() {
        let systemFontSources = self.systemFontSources()
        let systemFontModels = fontModelFactory.makeFontModels(from: systemFontSources)
        fontModelsRepository.addFonts(systemFontModels)
    }

    private func installCustomFonts(completion: (() -> Void)?) {
        logger.debug("Started installing custom fonts")
        analyticsService.trackEvent(FontsServiceStartedInstallingFontsAnalyticsEvent())

        let bundle = Bundle(for: Self.self)

        guard
            let customFontFileURLs = bundle.urls(
                forResourcesWithExtension: Constants.defaultFontExtension,
                subdirectory: nil
            )
        else {
            logger.error("Failed to install custom fonts", description: "No font URLs")
            return
        }

        let dispatchGroup = DispatchGroup()
        var installedFontModels: [FontModel] = []

        // TODO: FIX MEMORY ISSUE AT KEYBOARD
        let fontsToInstallURLs = customFontFileURLs.prefix(50)
        for customFontFileURL in fontsToInstallURLs {
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
                        logger.error("Failed to install custom font", error: error)

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

            completion?()

            self.analyticsService.trackEvent(FontsServiceFinishedInstallingFontsAnalyticsEvent())
        }
    }

    // MARK: - Installing Font

    private func installSystemFont(
        with name: String,
        completion: @escaping FontInstallationCompletion
    ) {
        guard UIFont.familyNames.contains(name) else {
            completion(.failure(.notPresentInSystem(fontName: name)))
            return
        }

        let fontModel = FontModel(name: name, resourceType: .system(fontName: name), status: .ready)
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
            complete(with: .failure(.failedToCreateCGDataProvider(resourceType)))
            return
        }
        guard let cgFont = CGFont(dataProvider) else {
            complete(with: .failure(.failedToCreateCGFont(resourceType)))
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
            complete(with: .failure(.missingFontName(resourceType)))
            return
        }

        let fontName = String(cfFontName)
        let fontModel = FontModel(
            name: fontName,
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
            logger.error("Error restoring last used Language", error: error)
        }

        return nil
    }

    private func storeLastUsedLanguage(_ language: KeyboardType.Language) {
        do {
            try keychainContainer.setString("\(language.rawValue)", for: Constants.lastUsedLanguageKey)
        } catch {
            logger.error("Error storing last used Language", error: error)
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
            logger.error("Error restoring last used CanvasViewDesign", error: error)
        }

        return nil
    }

    private func storeLastUsedCanvasViewDesign(_ canvasViewDesign: CanvasViewDesign) {
        do {
            let canvasViewDesignData = try JSONEncoder().encode(canvasViewDesign)
            try keychainContainer.setData(canvasViewDesignData, for: Constants.lastUsedCanvasViewDesignKey)
        } catch {
            logger.error("Error storing last used CanvasViewDesign", error: error)
        }
    }

    private func systemFontSources() -> [FontSourceModel] {
        let systemFonts = UIFont.familyNames.compactMap { fontName -> FontSourceModel? in
            guard !fontName.lowercased().contains("system") else { return nil }
            return FontSourceModel(name: fontName, resourceType: .system(fontName: fontName))
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

    static let defaultLastUsedFontModel: FontModel = {
        let fontName: String = "Georgia-Bold"
        return FontModel(
            name: fontName,
            resourceType: .system(fontName: fontName),
            status: .ready
        )
    }()
    static let defaultCanvasViewDesign: CanvasViewDesign = .default(fontModel: defaultLastUsedFontModel)
}
