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

    // MARK: - Nested Types

    struct FontListSection {
        let fontViewModels: [FontListFontViewModel]
    }

    struct TitleSection {
        let titleViewModel: FontListTitleCell.ViewModel
        let titleDesign: FontListTitleCell.Design
    }

    struct BannerSection {
        let bannerViewModel: FontListBannerCell.ViewModel
        let bannerDesign: FontListBannerCell.Design
    }

    enum Section {
        case banner(BannerSection)
        case title(TitleSection)
        case fontList(FontListSection)
    }

    // MARK: - Public Instance Properties

    var sections: [Section] = []

    let didTapKeyboardInstallBanner = Event<Void>()
    let shouldReloadDataEvent = Event<Void>()

    // MARK: - Private Instance Properties

    // TODO: Use DependencyInjection instead of Singleton
    private let fontsService: FontsService = DefaultFontsService.shared
    private let fontsRepository: FontsRepository = DefaultFontsRepository.shared

    private var keyboardInstallBannerSection: BannerSection?
    private var fontListTitleSection: TitleSection?
    private var fontListSection: FontListSection

    init() {
        let bannerViewModel = FontListBannerCell.ViewModel(title: Constants.installBannerText)
        keyboardInstallBannerSection = BannerSection(
            bannerViewModel: bannerViewModel,
            bannerDesign: .keyboardInstall
        )
        fontListTitleSection = TitleSection(
            titleViewModel: .init(title: "Explore system fonts"),
            titleDesign: .fontListTitle
        )
        let fontViewModels = fontsRepository.fonts.map { FontListFontViewModel(withModel: $0) }
        fontListSection = .init(fontViewModels: fontViewModels)

        sections = makeSections()
        setupBusinessLogic(bannerViewModel: bannerViewModel)
    }

    // MARK: - Public Instance Properties

    func installFont(from fontSourceModel: FontSourceModel) {
        fontsService.installFont(from: fontSourceModel) { result in
            switch result {
            case let .success(fontModel):
                print("Successfully installed font \(fontModel)")

            case let .failure(error):
                print("Failed to installed font from source \(fontSourceModel) with error \(error)")
            }
        }
    }

    // MARK: - Private Instance Properties

    private func setupBusinessLogic(bannerViewModel: FontListBannerCell.ViewModel) {
        bannerViewModel.didTapEvent.subscribe(self) { [weak self] in
            self?.didTapKeyboardInstallBanner.onNext(())
        }

        fontsRepository.didUpdateFontsEvent.subscribe(self) { [weak self] in
            guard let self = self else { return }
            self.updateData()
            self.shouldReloadDataEvent.onNext(())
        }
    }

    private func makeSections() -> [Section] {
        var result: [Section] = []
        if let keyboardInstallBannerSection = keyboardInstallBannerSection {
            result.append(.banner(keyboardInstallBannerSection))
        }
        if let fontListTitleSection = fontListTitleSection {
            result.append(.title(fontListTitleSection))
        }
        result.append(.fontList(fontListSection))
        return result
    }

    private func updateData() {
        let fontViewModels = fontsRepository.fonts.map { FontListFontViewModel(withModel: $0) }
        fontListSection = .init(fontViewModels: fontViewModels)

        sections = makeSections()
    }
}

private extension FontListBannerCell.Design {

    static let keyboardInstall = FontListBannerCell.Design(
        minHeightToWidthAspectRatio: 9.0 / 16.0,
        contentInsets: .init(vertical: 16, horizontal: 16),
        font: UIFont(name: "AvenirNext-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium),
        textColor: .white,
        backgroundColor: Colors.brandMainLight,
        cornerRadius: 16,
        shadow: .init(
            color: Colors.brandMainLight,
            alpha: 0.8,
            x: 0,
            y: 16,
            blur: 32,
            spread: -16
        )
    )
}

private extension FontListTitleCell.Design {

    static let fontListTitle: FontListTitleCell.Design = .init(
        font: UIFont(name: "AvenirNext-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium),
        textColor: Colors.textMinor
    )
}

private enum Constants {

    static let installBannerText = """
    Welcome 😎
    Tap here to add our Keyboard ⌨️
    Go to "Keyboards" > "Fontastic"
    Also, please enable "Full Access"
    """
}
