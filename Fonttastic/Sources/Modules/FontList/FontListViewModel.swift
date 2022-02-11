//
//  FontListViewModel.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 06.10.2021.
//

import Foundation
import UIKit
import FonttasticTools

class FontListViewModel {

    // MARK: - Internal Instance Properties

    let fontListCollectionViewModel: FontListCollectionViewModel

    // MARK: - Private Instance Properties

    private let fontsService: FontsService = DefaultFontsService.shared

    init(mode: FontListCollectionViewModel.Mode) {
        self.fontListCollectionViewModel = FontListCollectionViewModel(mode: mode)
    }

    // MARK: - Public Instance Properties

    func installFont(from fontSourceModel: FontSourceModel) {
        fontsService.installFont(from: fontSourceModel) { result in
            switch result {
            case let .success(fontModel):
                logger.debug("Successfully installed font \(fontModel)")

            case let .failure(error):
                logger.error(
                    "Failed to installed font",
                    description: "FontsSource: \(fontSourceModel)",
                    error: error
                )
            }
        }
    }

    // MARK: - Internal Instance Properties

    func reloadData() {
        fontListCollectionViewModel.reloadData()
    }
}
