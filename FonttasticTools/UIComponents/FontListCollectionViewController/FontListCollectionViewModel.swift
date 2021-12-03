//
//  FontListViewModel.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 06.10.2021.
//

import Foundation
import UIKit

public class FontListCollectionViewModel {

    // MARK: - Nested Types

    public struct FontListSection {
        let fontViewModels: [FontListFontViewModel]
    }

    public struct TitleSection {
        let titleViewModel: FontListTitleCell.ViewModel
        let titleDesign: FontListTitleCell.Design
    }

    public struct BannerSection {
        let bannerViewModel: FontListBannerCell.ViewModel
        let bannerDesign: FontListBannerCell.Design
    }

    public struct LoaderSection {
        let loaderDesign: FontListLoaderCell.Design
    }

    public enum Section {
        case banner(BannerSection)
        case title(TitleSection)
        case fontList(FontListSection)
        case loader(LoaderSection)
    }

    public enum Mode {
        case fontsShowcase
        case fontSelection(language: KeyboardType.Language)
    }

    // MARK: - Public Instance Properties

    private let mode: Mode
    public var sections: [Section] = []

    public let didTapBannerEvent = Event<Void>()
    public let didTapFontCell = Event<FontListFontViewModel>()
    let shouldReloadDataEvent = Event<Void>()

    // MARK: - Private Instance Properties

    private let fontsService: FontsService = DefaultFontsService.shared
    private var fontModelsRepository: FontModelsRepository { fontsService.fontModelsRepository }
    private var appStatusService: AppStatusService = DefaultAppStatusService.shared

    public init(mode: Mode) {
        self.mode = mode

        updateData()
        setupBusinessLogic()
    }

    // MARK: - Public Instance Methods

    // MARK: - Private Instance Methods

    private func setupBusinessLogic() {
        fontModelsRepository.didUpdateFontsEvent.subscribe(self) { [weak self] in
            guard let self = self else { return }
            self.updateData()
            self.shouldReloadDataEvent.onNext(())
        }
    }

    private func updateData() {
        sections = makeSections()
    }

    private func makeSections() -> [Section] {
        switch mode {
        case .fontsShowcase:
            return makeSectionsForFontsShowcase(appStatus: appStatusService.appStatus)

        case .fontSelection:
            return makeSectionsForFontSelection()
        }
    }

    private func makeSectionsForFontsShowcase(appStatus: AppStatus) -> [Section] {
        var result: [Section] = []

        // Banner

        let bannerViewModel: FontListBannerCell.ViewModel?
        switch (appStatus.appSubscriptionStatus, appStatus.keyboardInstallationStatus) {
        case (_, .notInstalled), (_, .installedWithLimitedAccess):
            bannerViewModel = FontListBannerCell.ViewModel(title: Constants.keyboardInstallBannerText)

        case (.noSubscription, _):
            bannerViewModel = FontListBannerCell.ViewModel(title: Constants.subscriptionPurchaseBannerText)

        case (.hasActiveSubscription, .installedWithFullAccess):
            bannerViewModel = nil
        }
        if let bannerViewModel = bannerViewModel {
            bannerViewModel.didTapEvent.subscribe(self) { [weak self] in
                self?.didTapBannerEvent.onNext(())
            }
            let keyboardInstallBannerSection = BannerSection(
                bannerViewModel: bannerViewModel,
                bannerDesign: .default
            )
            result.append(.banner(keyboardInstallBannerSection))
        }

        // Custom Fonts

        let customFontsTitleSection = TitleSection(
            titleViewModel: .init(title: Strings.fontListCollectionSectionHeaderCustomFonts),
            titleDesign: .fontListTitle
        )
        result.append(.title(customFontsTitleSection))
        if fontsService.hasInstalledCustomFonts {
            let customFontViewModels = fontModelsRepository.fonts
                .filter { $0.resourceType != .system }
                .map { FontListFontViewModel(withModel: $0) }
            result.append(.fontList(FontListSection(fontViewModels: customFontViewModels)))
        } else {
            result.append(.loader(LoaderSection(loaderDesign: .default)))
        }

        // System Fonts

        let fontListTitleSection = TitleSection(
            titleViewModel: .init(title: Strings.fontListCollectionSectionHeaderSystemFonts),
            titleDesign: .fontListTitle
        )
        result.append(.title(fontListTitleSection))

        let systemFontViewModels = fontModelsRepository.fonts
            .filter { $0.resourceType == .system }
            .map { FontListFontViewModel(withModel: $0) }
        result.append(.fontList(FontListSection(fontViewModels: systemFontViewModels)))

        return result
    }

    private func makeSectionsForFontSelection() -> [Section] {
        var result: [Section] = []
        let availableFontModels = getAvailableFontModels(for: mode)

        // Custom Fonts

        let customFontsTitleSection = TitleSection(
            titleViewModel: .init(title: Strings.fontListCollectionSectionHeaderCustomFonts),
            titleDesign: .fontListTitle
        )
        result.append(.title(customFontsTitleSection))
        if fontsService.hasInstalledCustomFonts {
            let customFontViewModels = availableFontModels
                .filter { $0.resourceType != .system }
                .map { FontListFontViewModel(withModel: $0) }
            result.append(.fontList(FontListSection(fontViewModels: customFontViewModels)))
        } else {
            result.append(.loader(LoaderSection(loaderDesign: .default)))
        }

        // System Fonts

        let fontListTitleSection = TitleSection(
            titleViewModel: .init(title: Strings.fontListCollectionSectionHeaderSystemFonts),
            titleDesign: .fontListTitle
        )
        result.append(.title(fontListTitleSection))

        let systemFontViewModels = availableFontModels
            .filter { $0.resourceType == .system }
            .map { FontListFontViewModel(withModel: $0) }
        result.append(.fontList(FontListSection(fontViewModels: systemFontViewModels)))

        return result
    }

    // MARK: - Utils

    private func getAvailableFontModels(for mode: Mode) -> [FontModel] {
        let allFontModels = fontModelsRepository.fonts
        switch mode {
        case .fontsShowcase:
            return allFontModels

        case let .fontSelection(language):
            guard case .cyrillic = language else { return allFontModels }
            return allFontModels.filter { fontModel -> Bool in
                let ctFont = CTFontCreateWithName(fontModel.name as CFString, Constants.dummyFontSize, nil)
                guard let supportedLanguages = CTFontCopySupportedLanguages(ctFont) as? [String] else { return false }
                return supportedLanguages.contains(Constants.russianLanguageID)
            }
        }
    }
}

private extension FontListBannerCell.Design {

    static let `default` = FontListBannerCell.Design(
        minHeightToWidthAspectRatio: 1.0 / 5.0,
        contentInsets: .init(vertical: 16, horizontal: 16),
        font: UIFont(name: "AvenirNext-Medium", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .medium),
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
        font: UIFont(name: "AvenirNext-Demibold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .semibold),
        textColor: Colors.titleMinor
    )
}

private extension FontListLoaderCell.Design {

    static let `default` = FontListLoaderCell.Design(height: 64)
}

private enum Constants {

    static let keyboardInstallBannerText: String = Strings.fontListCollectionBannerTitleKeyboardInstall
    static let subscriptionPurchaseBannerText: String = Strings.fontListCollectionBannerTitleSubscriptionPurchase

    static let russianLanguageID: String = "ru"
    static let dummyFontSize: CGFloat = 24.0
}
