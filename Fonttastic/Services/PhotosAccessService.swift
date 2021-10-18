//
//  PhotosAccessService.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 17.10.2021.
//

import UIKit
import Photos

typealias PhotosAccessResult = Bool
typealias PhotosAccessCompletion = (PhotosAccessResult) -> Void

class PhotosAccessService {

    // MARK: - Internal Type Properties

    static let shared = PhotosAccessService()

    // MARK: - Initializers

    private init() {}

    // MARK: - Internal Instance Methods

    func grantPhotosAccess(_ completion: @escaping PhotosAccessCompletion) {
        func complete(with result: PhotosAccessResult) {
            DispatchQueue.main.async {
                completion(result)
            }
        }

        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized, .limited:
                complete(with: true)

            case .denied, .notDetermined, .restricted:
                complete(with: false)

            @unknown default:
                complete(with: false)
            }
        }
    }

    // MARK: - Private Instance Methods
}
