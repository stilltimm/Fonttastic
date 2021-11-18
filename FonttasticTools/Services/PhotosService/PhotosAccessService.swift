//
//  PhotosAccessService.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 17.10.2021.
//

import UIKit
import Photos

public typealias PhotosAccessResult = Bool
public typealias PhotosAccessCompletion = (PhotosAccessResult) -> Void

public protocol PhotosAccessService {

    func grantPhotosAccess(_ completion: @escaping PhotosAccessCompletion)
}

public  class DefaultPhotosAccessService: PhotosAccessService {

    // MARK: - Internal Type Properties

    public static let shared = DefaultPhotosAccessService()

    // MARK: - Initializers

    private init() {}

    // MARK: - Internal Instance Methods

    public func grantPhotosAccess(_ completion: @escaping PhotosAccessCompletion) {
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
}
