//
//  KeyboardViewModel.swift
//  FontasticKeyboard
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import FonttasticTools

final class KeyboardViewModel {

    // MARK: - Nested Types

    enum RowItem {
        case caseChangeButton(CaseChangeKeyboardButtonViewModel, KeyboardButtonDesign)
        case button(KeyboardButtonViewModelProtocol, KeyboardButtonDesign)
        case nestedRow(Row)
    }

    class Row {
        let items: [RowItem]
        let spacing: CGFloat

        init(items: [RowItem], spacing: CGFloat) {
            self.items = items
            self.spacing = spacing
        }
    }

    struct Design {
        let containerWidth: CGFloat
        let defaultFunctionalButtonWidth: CGFloat
        let letterWidth: CGFloat
        let letterSpacing: CGFloat
        let rowSpacing: CGFloat
        let edgeInsets: UIEdgeInsets
        let defaultButtonDesign: KeyboardButtonDesign
    }

    struct Config {
        let firstRowSources: [FontSymbolSourceModel]
        let secondRowSources: [FontSymbolSourceModel]
        let thirdRowSources: [FontSymbolSourceModel]
        let keyboardType: KeyboardType
    }

    // MARK: - Internal Instance Properties

    let rows: [Row]
    let design: Design
    let config: Config

    let didSubmitSymbolEvent: Event<String>
    let shouldDeleteSymbolEvent: Event<Void>
    let languageToggleEvent: Event<Void>
    let punctuationSetToggleEvent: Event<Void>
    let punctuationLanguageToggleEvent: Event<Void>

    // MARK: - Private Instance Properties

    private let isCapitalizedSourceEvent: HotEvent<Bool>

    // MARK: - Initializers

    private init(
        rows: [Row],
        design: Design,
        config: Config,
        didSubmitSymbolEvent: Event<String>,
        shouldDeleteSymbolEvent: Event<Void>,
        languageToggleEvent: Event<Void>,
        punctuationSetToggleEvent: Event<Void>,
        punctuationLanguageToggleEvent: Event<Void>,
        isCapitalizedSourceEvent: HotEvent<Bool>
    ) {
        self.rows = rows
        self.design = design
        self.config = config

        self.didSubmitSymbolEvent = didSubmitSymbolEvent
        self.shouldDeleteSymbolEvent = shouldDeleteSymbolEvent
        self.languageToggleEvent = languageToggleEvent
        self.punctuationSetToggleEvent = punctuationSetToggleEvent
        self.punctuationLanguageToggleEvent = punctuationLanguageToggleEvent
        self.isCapitalizedSourceEvent = isCapitalizedSourceEvent
    }

    // swiftlint:disable:next function_body_length
    convenience init(
        config: Config,
        lastUsedLanguageSource: Event<KeyboardType.Language>
    ) {
        let maxItemsInRow = max(
            config.firstRowSources.count,
            config.secondRowSources.count,
            config.thirdRowSources.count
        )
        let design: Design = .default(largestSymbolRowCount: maxItemsInRow)

        // Events setup

        let didSubmitSymbolEvent = Event<String>()
        let shouldDeleteSymbolEvent = Event<Void>()
        let languageToggleEvent = Event<Void>()
        let punctuationSetToggleEvent = Event<Void>()
        let punctuationLanguageToggleEvent = Event<Void>()
        let isCapitalizedSourceEvent = HotEvent<Bool>(value: false)

        // Letters rows setup

        let symbolRows: [[FontSymbolSourceModel]] = [
            config.firstRowSources,
            config.secondRowSources,
            config.thirdRowSources
        ]
        let symbolRowItems: [[KeyboardViewModel.RowItem]] = symbolRows
            .map { row -> [KeyboardViewModel.RowItem] in
                row.map { symbolSourceModel -> KeyboardViewModel.RowItem in
                    let symbolViewModel: KeyboardButtonViewModelProtocol
                    switch symbolSourceModel {
                    case let .capitalizableSymbol(lowercase, uppercase):
                        symbolViewModel = CapitalizableKeyboardButtonViewModel(
                            uncapitalizedSymbol: lowercase,
                            capitalizedSymbol: uppercase,
                            capitalizationSource: isCapitalizedSourceEvent
                        )

                    case let .symbol(symbol):
                        symbolViewModel = DefaultKeyboardButtonViewModel(symbol: symbol)
                    }
                    symbolViewModel.didTapEvent
                        .subscribe(didSubmitSymbolEvent) { [weak didSubmitSymbolEvent] content in
                            switch content {
                            case let .text(text, _):
                                guard let text = text else { break }
                                didSubmitSymbolEvent?.onNext(text)

                            default:
                                break
                            }
                        }
                    return KeyboardViewModel.RowItem.button(symbolViewModel, design.defaultButtonDesign)
                }
            }
        let firstRowSymbolItems = symbolRowItems[0]
        let secondRowSymbolItems = symbolRowItems[1]
        let thirdRowSymbolItems = symbolRowItems[2]

        // Functional buttons setup

        var thirdRowItems: [RowItem] = []
        let buttonDesignBuilder = KeyboardButtonDesignBuilder(design.defaultButtonDesign)

        let thinFunctionalButtonDesign = buttonDesignBuilder
            .withLayoutWidth(.fixed(width: design.letterWidth))
            .withForegroungColor(Colors.keyboardButtonMinor)
            .withHighlightedForegroundColor(Colors.keyboardButtonMain)
            .withIsMagnificationEnabled(false)
            .withPressSoundID(Sounds.caseChangeKeyPress)
            .build()
        let defaultFunctionalButtonDesign = buttonDesignBuilder
            .withLayoutWidth(.fixed(width: design.defaultFunctionalButtonWidth))
            .build()

        let thirdRowFunctionalButtonDesign: KeyboardButtonDesign
        switch config.keyboardType {
        case .language(.cyrillic):
            thirdRowFunctionalButtonDesign = thinFunctionalButtonDesign

        case .language(.latin), .punctuation:
            thirdRowFunctionalButtonDesign = defaultFunctionalButtonDesign
        }

        switch config.keyboardType {
        case .language:
            let caseChangeButtonViewModel = CaseChangeKeyboardButtonViewModel(
                capitalizationSource: isCapitalizedSourceEvent,
                textInsertedSource: didSubmitSymbolEvent
            )
            thirdRowItems.append(.caseChangeButton(caseChangeButtonViewModel, thirdRowFunctionalButtonDesign))

        case let .punctuation(punctuationSet):
            let punctuationChangeButtonViewModel = PunctuationSetToggleKeyboardButtonViewModel(
                punctuationSet: punctuationSet,
                punctuationSetToggleEvent: punctuationSetToggleEvent
            )
            let punctuationChangeButtonDesign = KeyboardButtonDesignBuilder(thirdRowFunctionalButtonDesign)
                .withLabelFont(UIFont.systemFont(ofSize: 12.0, weight: .regular))
                .build()
            thirdRowItems.append(.button(punctuationChangeButtonViewModel, punctuationChangeButtonDesign))
        }

        let backspaceViewModel = BackspaceKeyboardButtonViewModel(shouldDeleteSymbolEvent: shouldDeleteSymbolEvent)
        let backspaceButtonDesign = KeyboardButtonDesignBuilder(thirdRowFunctionalButtonDesign)
            .withPressSoundID(Sounds.deleteKeyPress)
            .build()
        thirdRowItems.append(.nestedRow(.init(items: thirdRowSymbolItems, spacing: design.letterSpacing)))
        thirdRowItems.append(.button(backspaceViewModel, backspaceButtonDesign))

        var fourthRowItems: [KeyboardViewModel.RowItem] = []

        let languagePunctuationToggleButtonViewModel = LanguagePunctuationToggleKeyboardButtonViewModel(
            keyboardType: config.keyboardType,
            languagePunctuationToggleEvent: punctuationLanguageToggleEvent
        )
        fourthRowItems.append(.button(languagePunctuationToggleButtonViewModel, defaultFunctionalButtonDesign))

        let languageButtonDesign = buttonDesignBuilder
            .withLabelFont(UIFont.systemFont(ofSize: 16.0, weight: .regular))
            .build()
        let languageChangeButtonViewModel = LanguageToggleKeyboardButtonViewModel(
            lastUsedLanguageSource: lastUsedLanguageSource,
            languageToggleEvent: languageToggleEvent
        )
        fourthRowItems.append(.button(languageChangeButtonViewModel, languageButtonDesign))

        let spaceButtonViewModel = LatinSpaceKeyboardButtonViewModel()
        let spaceAndReturnButtonTotalWidth = design.containerWidth
            - (3 * design.letterSpacing)
            - (2 * design.defaultFunctionalButtonWidth)
        let spaceButtonDesign = buttonDesignBuilder
            .withLayoutWidth(.fixed(width: floor(spaceAndReturnButtonTotalWidth * 2 / 3)))
            .withForegroungColor(Colors.keyboardButtonMain)
            .withHighlightedForegroundColor(Colors.keyboardButtonMinor)
            .withIsMagnificationEnabled(false)
            .withPressSoundID(Sounds.defaultKeyPress)
            .build()
        fourthRowItems.append(.button(spaceButtonViewModel, spaceButtonDesign))
        let returnButtonViewModel = LatinReturnKeyboardButtonViewModel()
        let returnButtonDesign = buttonDesignBuilder
            .withLayoutWidth(.fixed(width: floor(spaceAndReturnButtonTotalWidth / 3)))
            .withForegroungColor(Colors.keyboardButtonMinor)
            .withHighlightedForegroundColor(Colors.keyboardButtonMain)
            .build()
        fourthRowItems.append(.button(returnButtonViewModel, returnButtonDesign))

        let additionalSymbolViewModels: [KeyboardButtonViewModelProtocol] = [
            spaceButtonViewModel,
            returnButtonViewModel
        ]
        additionalSymbolViewModels.forEach { viewModel in
            viewModel.didTapEvent.subscribe(didSubmitSymbolEvent) { [weak didSubmitSymbolEvent] content in
                switch content {
                case let .text(text, _):
                    guard let text = text else { break }
                    didSubmitSymbolEvent?.onNext(text)

                default:
                    break
                }
            }
        }

        let thirdRowSpacing: CGFloat
        switch config.keyboardType {
        case .language(.cyrillic):
            thirdRowSpacing = design.letterSpacing

        case .language(.latin), .punctuation:
            let thirdRowEmptySpace: CGFloat = design.containerWidth
            - (CGFloat(thirdRowSymbolItems.count) * design.letterWidth)
            - (CGFloat(thirdRowSymbolItems.count - 1) * design.letterSpacing)
            - (2.0 * design.defaultFunctionalButtonWidth)
            thirdRowSpacing = floor(thirdRowEmptySpace / 2)
        }

        self.init(
            rows: [
                .init(items: firstRowSymbolItems, spacing: design.letterSpacing),
                .init(items: secondRowSymbolItems, spacing: design.letterSpacing),
                .init(items: thirdRowItems, spacing: thirdRowSpacing),
                .init(items: fourthRowItems, spacing: design.letterSpacing)
            ],
            design: design,
            config: config,
            didSubmitSymbolEvent: didSubmitSymbolEvent,
            shouldDeleteSymbolEvent: shouldDeleteSymbolEvent,
            languageToggleEvent: languageToggleEvent,
            punctuationSetToggleEvent: punctuationSetToggleEvent,
            punctuationLanguageToggleEvent: punctuationLanguageToggleEvent,
            isCapitalizedSourceEvent: isCapitalizedSourceEvent
        )
    }
}
