//
//  FileService.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 15.11.2021.
//

import Foundation
import ZIPFoundation

public enum FileServiceError: Error, CustomNSError {

    case failedToGetDocumentsDirectoryURL
    case zippedFilesButFileDoesNotExistAnymore(fileURL: URL)
    case unzippedArchiveButFileDoesNotExistAnymore(directoryURL: URL)

    // MARK: - Public Type Properties

    public static var errorDomain: String { "com.romandegtyarev.fonttastic.file-service" }

    // MARK: - Instance Properties

    public var errorCode: Int {
        switch self {
        case .failedToGetDocumentsDirectoryURL:
            return 0

        case .zippedFilesButFileDoesNotExistAnymore:
            return 1

        case .unzippedArchiveButFileDoesNotExistAnymore:
            return 2
        }
    }

    public var errorUserInfo: [String: Any] {
        switch self {
        case .failedToGetDocumentsDirectoryURL:
            return [
                NSLocalizedDescriptionKey: "Failed to get documents directory URL"
            ]

        case let .zippedFilesButFileDoesNotExistAnymore(fileURL):
            return [
                NSLocalizedDescriptionKey: "Zipped files, but file does not exist anymore",
                NSHelpAnchorErrorKey: fileURL.absoluteString
            ]

        case let .unzippedArchiveButFileDoesNotExistAnymore(directoryURL):
            return [
                NSLocalizedDescriptionKey: "Unzipped archive, but file does not exist anymore",
                NSHelpAnchorErrorKey: directoryURL.absoluteString
            ]
        }
    }
}

public protocol FileService {

    func documentsDirectoryURL() throws -> URL

    func deleteFileIfNeeded(at fileURL: URL) throws
    func recreateDirectoryIfNeeded(at directoryURL: URL) throws

    func write(fileContent: String, to fileUrl: URL) throws
    func contents(ofDirectory directoryURL: URL) throws -> [String]

    func makeZip(of url: URL, to archiveURL: URL) throws
    func unzip(archiveAt archiveURL: URL, to directoryURL: URL) throws
}

public class DefaultFileService: FileService {

    private let fileManager = FileManager.default

    public static let shared = DefaultFileService()

    private init() {}

    public func documentsDirectoryURL() throws -> URL {
        guard let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileServiceError.failedToGetDocumentsDirectoryURL
        }

        return documentsDirectoryURL
    }

    public func deleteFileIfNeeded(at fileURL: URL) throws {
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    public func recreateDirectoryIfNeeded(at directoryURL: URL) throws {
        try deleteFileIfNeeded(at: directoryURL)
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: false,
                attributes: nil
            )
        }
    }

    public func write(fileContent: String, to fileUrl: URL) throws {
        try fileContent.write(to: fileUrl, atomically: true, encoding: .utf8)
    }

    public func contents(ofDirectory directoryURL: URL) throws -> [String] {
        return try fileManager.contentsOfDirectory(atPath: directoryURL.path)
    }

    public func makeZip(of url: URL, to archiveURL: URL) throws {
        try deleteFileIfNeeded(at: archiveURL)
        try fileManager.zipItem(at: url, to: archiveURL)

        guard fileManager.fileExists(atPath: archiveURL.path) else {
            throw FileServiceError.zippedFilesButFileDoesNotExistAnymore(fileURL: archiveURL)
        }
    }

    public func unzip(archiveAt archiveURL: URL, to directoryURL: URL) throws {
        try recreateDirectoryIfNeeded(at: directoryURL)
        try fileManager.unzipItem(at: archiveURL, to: directoryURL)

        guard fileManager.fileExists(atPath: directoryURL.path) else {
            throw FileServiceError.unzippedArchiveButFileDoesNotExistAnymore(directoryURL: directoryURL)
        }
    }
}
