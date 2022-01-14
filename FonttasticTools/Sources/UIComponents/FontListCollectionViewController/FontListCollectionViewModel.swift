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

        var sectionInsets: UIEdgeInsets {
            switch self {
            case .banner, .fontList, .loader:
                return Constants.defaultSectionInsets

            case let .title(titleSection):
                return titleSection.titleDesign.edgeInsets
            }
        }
    }

    public enum Mode {
        case fontsShowcase
        case fontSelection(language: KeyboardType.Language)
    }

    // MARK: - Public Instance Properties

    private let mode: Mode
    public var sections: [Section] = []

    public let didTapBannerEvent = Event<FontListBannerType>()
    public let didTapFontCell = Event<FontListFontViewModel>()
    let shouldReloadDataEvent = Event<Void>()

    // MARK: - Private Instance Properties

    private let fontsService: FontsService = DefaultFontsService.shared
    private var fontModelsRepository: FontModelsRepository { fontsService.fontModelsRepository }
    private var appStatusService: AppStatusService = DefaultAppStatusService.shared

    public init(mode: Mode) {
        self.mode = mode

        reloadData()
        setupBusinessLogic()
    }

    // MARK: - Public Instance Methods

    public func reloadData() {
        sections = makeSections()
        self.shouldReloadDataEvent.onNext(())
    }

    // MARK: - Private Instance Methods

    private func setupBusinessLogic() {
        fontModelsRepository.didUpdateFontsEvent.subscribe(self) { [weak self] in
            guard let self = self else { return }
            self.reloadData()
        }
        appStatusService.appStatusDidUpdateEvent.subscribe(self) { [weak self] _ in
            self?.reloadData()
        }
    }

    private func makeSections() -> [Section] {
        switch mode {
        case .fontsShowcase:
            return makeSectionsForFontsShowcase(appStatus: appStatusService.appStatus)

        case .fontSelection:
            return makeSectionsForFontSelection()
        }
    }

    // swiftlint:disable:next function_body_length
    private func makeSectionsForFontsShowcase(appStatus: AppStatus) -> [Section] {
        var result: [Section] = []

        // Header

        let logoTitleSection = TitleSection(
            titleViewModel: FontListTitleCell.ViewModel(title: "Fonttastic"),
            titleDesign: .logo
        )
        result.append(.title(logoTitleSection))

        #if DEBUG
        let debugAppStatusSection = TitleSection(
            titleViewModel: FontListTitleCell.ViewModel(title: appStatus.description),
            titleDesign: .infoTitle
        )
        result.append(.title(debugAppStatusSection))
        #endif

        if let subscriptionInfo = appStatus.subscriptionState.subscriptionInfo {
            let subscriptionInfoSection = TitleSection(
                titleViewModel: FontListTitleCell.ViewModel(title: subscriptionInfo.localizedDescription),
                titleDesign: .infoTitle
            )
            result.append(.title(subscriptionInfoSection))
        } else if appStatus.subscriptionState.isLoading {
            result.append(.loader(LoaderSection(loaderDesign: .default)))
        }

        // Banner

        if let bannerType = FontListBannerType(appStatus: appStatus) {
            let bannerViewModel = FontListBannerCell.ViewModel(bannerType: bannerType)
            bannerViewModel.didTapEvent.subscribe(self) { [weak self] in
                self?.didTapBannerEvent.onNext(bannerType)
            }
            let keyboardInstallBannerSection = BannerSection(
                bannerViewModel: bannerViewModel,
                bannerDesign: .default
            )
            result.append(.banner(keyboardInstallBannerSection))
        }

        // Custom Fonts

        let customFontsTitleSection = TitleSection(
            titleViewModel: .init(title: FonttasticToolsStrings.FontListCollection.SectionHeader.customFonts),
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
            titleViewModel: .init(title: FonttasticToolsStrings.FontListCollection.SectionHeader.systemFonts),
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
            titleViewModel: .init(title: FonttasticToolsStrings.FontListCollection.SectionHeader.customFonts),
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
            titleViewModel: .init(title: FonttasticToolsStrings.FontListCollection.SectionHeader.systemFonts),
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
        minHeightToWidthAspectRatio: 9.0 / 16.0,
        contentInsets: .init(vertical: 16, horizontal: 16),
        font: UIFont(name: "AvenirNext-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium),
        textColor: .white,
        backgroundColor: Colors.brandMainLight,
        cornerRadius: 16,
        shadow: .init(
            color: Colors.brandMainLight,
            alpha: 0.5,
            x: 0,
            y: 16,
            blur: 32,
            spread: -16
        )
    )
}

private extension FontListTitleCell.Design {

    static let logo: FontListTitleCell.Design = FontListTitleCell.Design(
        font: UIFont(name: "Futura-Bold", size: 48) ?? UIFont.systemFont(ofSize: 48, weight: .bold),
        textColor: Colors.blackAndWhite,
        edgeInsets: UIEdgeInsets(top: 16, left: 16, bottom: 4, right: 16),
        shadow: nil
    )

    static let infoTitle: FontListTitleCell.Design = FontListTitleCell.Design(
        font: UIFont(name: "AvenirNext-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16),
        textColor: Colors.blackAndWhite,
        edgeInsets: UIEdgeInsets(top: 0, left: 16, bottom: 4, right: 16),
        shadow: nil
    )

    static let fontListTitle: FontListTitleCell.Design = FontListTitleCell.Design(
        font: UIFont(name: "AvenirNext-DemiBold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .semibold),
        textColor: Colors.blackAndWhite,
        edgeInsets: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16),
        shadow: nil
    )
}

private extension FontListLoaderCell.Design {

    static let `default` = FontListLoaderCell.Design(height: 64)
}

private enum Constants {

    static let russianLanguageID: String = "ru"
    static let dummyFontSize: CGFloat = 24.0
    static let defaultSectionInsets: UIEdgeInsets = UIEdgeInsets(vertical: 16, horizontal: 16)
}
