//
//  FontsService.swift
//  Fontastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import Foundation
import CoreFoundation
import CoreText

// MARK: - Supporting Types

enum FontDownloadError: Error {
    case networkError
}
enum FontCreationError: Error {
    case failedToCreateCGDataProvider
    case failedToCreateCGFont
    case failedToRegisterFont(String?)
    case missingFontName
    case networkError
}

typealias FontFetchResult = Result<FontModel, FontDownloadError>
typealias FontCreationResult = Result<FontModel, FontCreationError>

typealias FontFetchCompletion = (FontFetchResult) -> Void
typealias FontCreationCompletion = (FontCreationResult) -> Void

// MARK: - FontsService

protocol FontsService {

    func fetchFont(withName name: String, completion: @escaping FontFetchCompletion)
    func saveCustomFont(withName name: String, data: Data, completion: @escaping FontCreationCompletion)
}

class DefaultFontsService: FontsService {

    // MARK: - Initializers

    init() {

    }

    // MARK: - Public Methods

    func fetchFont(withName name: String, completion: @escaping FontFetchCompletion) {
        #warning("TODO: implement")
    }

    func saveCustomFont(withName name: String, data: Data, completion: @escaping FontCreationCompletion) {
        func complete(with result: FontCreationResult) {
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
        let fontModel = FontModel(name: fontName, type: .userCreated)

        #warning("TODO: Save to repository")

        complete(with: .success(fontModel))
    }
}
