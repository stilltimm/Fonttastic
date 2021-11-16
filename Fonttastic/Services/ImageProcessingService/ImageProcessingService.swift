//
//  ImageProcessingService.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 17.10.2021.
//

import Foundation
import UIKit
import FonttasticToolsStatic
import ZIPFoundation

// MARK: - Supporting Types

enum AlphabetTypeResolutionError: Error {

    case undefinedImageRatio(imageRatio: CGFloat, knownAlphabetTypes: [AlphabetType])

    var localizedDescription: String {
        switch self {
        case let .undefinedImageRatio(imageRatio, knownAlphabetTypes):
            var resultString: String = "Undefined image ratio \(imageRatio)"
            resultString += "\nSource image should follow one of this rules:"
            knownAlphabetTypes.forEach { alphabetType in
                resultString += "\n- \(alphabetType.title)"
                resultString += "\n  - Image consists of: \(alphabetType.imageTipText)"
                resultString += "\n  - Expected ratio: \(alphabetType.imageRatio) : 1.0"
            }
            return resultString
        }
    }
}
typealias AlphabetTypeResolutionResult = Result<AlphabetType, AlphabetTypeResolutionError>
typealias AlphabetTypeResolutionCompletion = (AlphabetTypeResolutionResult) -> Void

enum BitmapAlphabetSourceCreationError: Error {

    case imageMismatchesAlphabetType(imageRatio: CGFloat, alphabetType: AlphabetType)
    case imageRatioMismtachesLettersCount(imageRatio: CGFloat, lettersCount: Int)
    case failedToSliceImage(cropRect: CGRect)

    var localizedDescription: String {
        switch self {
        case let .imageMismatchesAlphabetType(imageRatio, alphabetType):
            var resultString: String = "Source image ratio (\(imageRatio)) mismatches expected alphabet ratio."
            resultString += "\nExpected alphabet type: \(alphabetType.title), ratio: \(alphabetType.imageRatio)"
            return resultString

        case let .imageRatioMismtachesLettersCount(imageRatio, lettersCount):
            var resultString: String = "Source image ratio (\(imageRatio)) mismatches"
            resultString += " expected alphabet letters count (\(lettersCount))"
            return resultString

        case let .failedToSliceImage(cropRect):
            return "Failed to slice image at rect \(cropRect)"
        }
    }
}
typealias BitmapAlphabetSourceCreationResult = Result<BitmapAlphabetSourceModel, BitmapAlphabetSourceCreationError>
typealias BitmapAlphabetSourceCreationCompletion = (BitmapAlphabetSourceCreationResult) -> Void

enum SVGAlphabetSourceCreationError: Error {

    case failedToExportPixelData(bitmapLetterSource: BitmapLetterSourceModel)

    var localizedDescription: String {
        switch self {
        case let .failedToExportPixelData(bitmapLetterSource):
            var resultString: String = "Failed to export pixel data from letter source. "
            resultString += "Expected letter: \(bitmapLetterSource.letter), image: \(bitmapLetterSource.image)"
            return resultString
        }
    }
}
typealias SVGAlphabetSourceCreationResult = Result<SVGAlphabetSourceModel, SVGAlphabetSourceCreationError>
typealias SVGAlphabetSourceCreationCompletion = (SVGAlphabetSourceCreationResult) -> Void

// MARK: - Protocol

protocol ImageProcessingService {

    func resolveAlphabetType(
        from image: UIImage,
        completion: @escaping AlphabetTypeResolutionCompletion
    )

    func makeBitmapAlphabetSource(
        from image: UIImage,
        for alphabetType: AlphabetType,
        completion: @escaping BitmapAlphabetSourceCreationCompletion
    )

    func makeSVGAlphabetSource(
        from bitmapAlphabetSource: BitmapAlphabetSourceModel,
        completion: @escaping SVGAlphabetSourceCreationCompletion
    )

    func tryCreateSVGsArchive(
        from svgAlphabetSource: SVGAlphabetSourceModel
    ) -> URL?
}

// MARK: - Default Implementaton

class DefaultImageProcessingService: ImageProcessingService {

    // MARK: - Internal Type Properties

    static let shared = DefaultImageProcessingService()

    // MARK: - Private Type Properties

    private static let isLoggingEnabled: Bool = true
    private static let fileName = #file.components(separatedBy: "/").last!

    // MARK: - Private Type Methods

    private static func logIfEnabled(
        title: String = "",
        startDate: Date,
        endDate: Date = Date(),
        function: String = #function
    ) {
        let timePassed = endDate.timeIntervalSince(startDate)
        logger.log("\(function): \(title) took \(timePassed) seconds", level: .debug)
    }

    // MARK: - Private Instance Properties

    private let fileService: FileService = DefaultFileService.shared

    // MARK: - Initializers

    private init() {}

    // MARK: - Instance Methods

    func resolveAlphabetType(
        from image: UIImage,
        completion: @escaping AlphabetTypeResolutionCompletion
    ) {
        let startDate = Date()
        let function = #function
        func complete(with result: AlphabetTypeResolutionResult) {
            Self.logIfEnabled(startDate: startDate, function: function)
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let imageRatio = image.size.width / image.size.height
        let alphabetTypesWithRatios = AlphabetType.allCases.map { (type: $0, ratio: $0.imageRatio) }

        guard let alphabetType = alphabetTypesWithRatios.first(where: { $0.ratio == imageRatio })?.type else {
            complete(
                with: .failure(
                    .undefinedImageRatio(imageRatio: imageRatio, knownAlphabetTypes: AlphabetType.allCases)
                )
            )
            return
        }

        complete(with: .success(alphabetType))
    }

    func makeBitmapAlphabetSource(
        from image: UIImage,
        for alphabetType: AlphabetType,
        completion: @escaping BitmapAlphabetSourceCreationCompletion
    ) {
        let startDate = Date()
        let function = #function
        func complete(with result: BitmapAlphabetSourceCreationResult) {
            Self.logIfEnabled(startDate: startDate, function: function)
            DispatchQueue.main.async {
                completion(result)
            }
        }

        /// NOTE:  check image ratio against alphabet ratio
        let imageHeight = image.size.height
        let imageWidth = image.size.width
        let imageRatio = imageWidth / imageHeight
        guard imageRatio == alphabetType.imageRatio else {
            complete(with: .failure(.imageMismatchesAlphabetType(imageRatio: imageRatio, alphabetType: alphabetType)))
            return
        }

        /// NOTE:  check image ratio against letters count
        let orderedLetters = alphabetType.orderedLetters
        guard imageWidth == CGFloat(orderedLetters.count) * imageHeight else {
            complete(
                with: .failure(
                    .imageRatioMismtachesLettersCount(imageRatio: imageRatio, lettersCount: orderedLetters.count)
                )
            )
            return
        }

        /// NOTE:  slice image and make bitmap letter sources
        let letterSources: [BitmapLetterSourceModel]
        switch makeBitmapLetterSources(from: image, orderedLetters: orderedLetters) {
        case let .failure(error):
            complete(with: .failure(error))
            return

        case let .success(letterSourceModels):
            letterSources = letterSourceModels
        }

        /// NOTE:  create bitmap alphabet source model and complete
        let alphabetSourceModel = BitmapAlphabetSourceModel(
            alphabetType: alphabetType,
            letterSources: letterSources
        )
        complete(with: .success(alphabetSourceModel))
    }

    func makeSVGAlphabetSource(
        from bitmapAlphabetSource: BitmapAlphabetSourceModel,
        completion: @escaping SVGAlphabetSourceCreationCompletion
    ) {
        let startDate = Date()
        let function = #function
        func complete(with result: SVGAlphabetSourceCreationResult) {
            Self.logIfEnabled(startDate: startDate, function: function)
            DispatchQueue.main.async {
                completion(result)
            }
        }

        var svgLetterSources: [SVGLetterSourceModel] = []
        for bitmapLetterSourceModel in bitmapAlphabetSource.letterSources {
            guard
                let svgLetterSourceModel = makeSVGLetterSource(
                    from: bitmapLetterSourceModel,
                    with: Constants.defaultPotraceSettings
                )
            else {
                complete(with: .failure(.failedToExportPixelData(bitmapLetterSource: bitmapLetterSourceModel)))
                return
            }

            svgLetterSources.append(svgLetterSourceModel)
        }
        let svgAlphabetSourceModel = SVGAlphabetSourceModel(
            alphabetType: bitmapAlphabetSource.alphabetType,
            letterSources: svgLetterSources
        )
        complete(with: .success(svgAlphabetSourceModel))
    }

    func tryCreateSVGsArchive(
        from svgAlphabetSource: SVGAlphabetSourceModel
    ) -> URL? {
        do {
            let documentsDirectoryURL = try fileService.documentsDirectoryURL()
            let svgsDirectoryURL = documentsDirectoryURL.appendingPathComponent("svgs", isDirectory: true)
            let archiveURL = documentsDirectoryURL.appendingPathComponent("archive.zip")

            try fileService.recreateDirectoryIfNeeded(at: svgsDirectoryURL)
            for svgLetterSource in svgAlphabetSource.letterSources {
                let fileName = "\(svgLetterSource.letter)"
                let fileURL = svgsDirectoryURL.appendingPathComponent(fileName).appendingPathExtension("svg")
                try fileService.write(fileContent: svgLetterSource.svgContents, to: fileURL)
            }

            try fileService.makeZip(of: svgsDirectoryURL, to: archiveURL)
            return archiveURL
        } catch {
            logger.log("Failed to create archive: \(error)", level: .error)
            return nil
        }
    }

    // MARK: - Private Instance Methods

    private func makeBitmapLetterSources(
        from image: UIImage,
        orderedLetters: [LetterType]
    ) -> Result<[BitmapLetterSourceModel], BitmapAlphabetSourceCreationError> {
        let startDate = Date()
        let imageHeight = image.size.height
        var cropRect = CGRect(origin: CGPoint.zero, size: CGSize(width: imageHeight, height: imageHeight))

        var letterSources: [BitmapLetterSourceModel] = []
        for (i, letter) in orderedLetters.enumerated() {
            cropRect.origin.x = CGFloat(i) * imageHeight

            guard let croppedCgImage = image.cgImage?.cropping(to: cropRect) else {
                return .failure(.failedToSliceImage(cropRect: cropRect))
            }

            let croppedImage = UIImage(cgImage: croppedCgImage, scale: 1, orientation: image.imageOrientation)
            letterSources.append(.init(letter: letter, image: croppedImage))
        }

        Self.logIfEnabled(startDate: startDate)
        return .success(letterSources)
    }

    private func makeSVGLetterSource(
        from bitmapLetterSource: BitmapLetterSourceModel,
        with settings: Potrace.Settings
    ) -> SVGLetterSourceModel? {
        guard
            let pixelData = bitmapLetterSource.image.pixelData()
        else { return nil }

        let startDate = Date()

        // TODO: Fix this warning https://stackoverflow.com/a/60912479
        let potrace = Potrace(
            data: UnsafeMutableRawPointer(mutating: pixelData),
            width: Int(bitmapLetterSource.image.size.width),
            height: Int(bitmapLetterSource.image.size.height)
        )

        potrace.process(settings: settings)

        let scale: Double = Constants.lineHeight / Double(bitmapLetterSource.image.size.height)
        let result: SVGLetterSourceModel = SVGLetterSourceModel(
            letter: bitmapLetterSource.letter,
            svgContents: potrace.getSVG(scale: scale, opt_type: nil),
            bezierPath: potrace.getBezierPath(scale: 4)
        )

        Self.logIfEnabled(title: "Letter \"\(bitmapLetterSource.letter)\"", startDate: startDate)
        return result
    }
}

private extension UIImage {

    func pixelData() -> [UInt8]? {
        let size = self.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: &pixelData,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 4 * Int(size.width),
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        )
        guard let cgImage = self.cgImage else { return nil }

        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        return pixelData
    }
}

private enum Constants {

    static let defaultPotraceSettings: Potrace.Settings = {
        var settings = Potrace.Settings()
        settings.turdsize = 10
        settings.alphamax = 0.5
        settings.optcurve = false
        settings.opttolerance = 2.0
        return settings
    }()

    static let lineHeight: Double = 1000.0
}
