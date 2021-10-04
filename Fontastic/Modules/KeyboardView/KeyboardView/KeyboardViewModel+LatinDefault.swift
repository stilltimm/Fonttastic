//
//  LatinAlphabetQwertyKeyboardViewModel.swift
//  Fontastic
//
//  Created by Timofey Surkov on 02.10.2021.
//

import UIKit
import FontasticTools

class LatinAlphabetQwertyKeyboardViewModel: KeyboardViewModel {

    // MARK: - Private Type Properties

    fileprivate static let firstRowLetters: [(String, String)] = [
        ("q", "Q"),
        ("w", "W"),
        ("e", "E"),
        ("r", "R"),
        ("t", "T"),
        ("y", "Y"),
        ("u", "U"),
        ("i", "I"),
        ("o", "O"),
        ("p", "P"),
    ]
    fileprivate static let secondRowLetters: [(String, String)] = [
        ("a", "A"),
        ("s", "S"),
        ("d", "D"),
        ("f", "F"),
        ("g", "G"),
        ("h", "H"),
        ("j", "J"),
        ("k", "K"),
        ("l", "L"),
    ]
    fileprivate static let thirdRowLetters: [(String, String)] = [
        ("z", "Z"),
        ("x", "X"),
        ("c", "C"),
        ("v", "V"),
        ("b", "B"),
        ("n", "N"),
        ("m", "M"),
    ]
    fileprivate static func containerWidth(horizontalInsetsSum: CGFloat) -> CGFloat {
        return UIScreen.main.bounds.width - horizontalInsetsSum
    }
    fileprivate static func lettersWidth(containerWidth: CGFloat, letterSpacing: CGFloat) -> CGFloat {
        let widthWithoutSpacing = containerWidth - CGFloat(firstRowLetters.count - 1) * letterSpacing
        return floor(floor(widthWithoutSpacing) / CGFloat(firstRowLetters.count))
    }

    // MARK: - Public Instance Properties

    let didSubmitSymbolEvent: Event<String>
    let shouldDeleteSymbolEvent: Event<Void>

    // MARK: - Private Instance Properties

    private let isCapitalizedSourceEvent: HotEvent<Bool>

    init(design: Design) {

        // Events setup

        let symbolSumbitEvent = Event<String>()
        self.didSubmitSymbolEvent = symbolSumbitEvent

        let isCapitalizedSourceEvent = HotEvent<Bool>(value: false)
        self.isCapitalizedSourceEvent = isCapitalizedSourceEvent

        let shouldDeleteSymbolEvent = Event<Void>()
        self.shouldDeleteSymbolEvent = shouldDeleteSymbolEvent

        // Letters rows setup

        let lettersRows: [[(String, String)]] = [Self.firstRowLetters, Self.secondRowLetters, Self.thirdRowLetters]
        let lettersRowItems: [[KeyboardViewModel.RowItem]] = lettersRows
            .map { row -> [KeyboardViewModel.RowItem] in
                row
                    .map { (uncapitalized, capitalized) -> KeyboardViewModel.RowItem in
                        let symbolViewModel = CapitalizableKeyboardButtonViewModel(
                            uncapitalizedSymbol: uncapitalized,
                            capitalizedSymbol: capitalized,
                            capitalizationSource: isCapitalizedSourceEvent
                        )
                        symbolViewModel.didTapEvent.subscribe(symbolSumbitEvent) { [weak symbolSumbitEvent] content in
                            switch content {
                            case let .text(text, _):
                                symbolSumbitEvent?.onNext(text)

                            default: break
                            }
                        }
                        return KeyboardViewModel.RowItem.button(symbolViewModel, design.defaultButtonDesign)
                    }
            }
        let firstRowLetterItems = lettersRowItems[0]
        let secondRowLetterItems = lettersRowItems[1]
        let thirdRowLetterItems = lettersRowItems[2]

        // Functional buttons setup

        let caseChangeButtonViewModel = CaseChangeKeyboardButtonViewModel(
            capitalizationSource: isCapitalizedSourceEvent,
            textInsertedSource: symbolSumbitEvent
        )

        let backspaceViewModel = BackspaceKeyboardButtonViewModel(shouldDeleteSymbolEvent: shouldDeleteSymbolEvent)

        let buttonDesignBuilder = KeyboardButtonDesignBuilder(design.defaultButtonDesign)
        let functionalButtonDesign = buttonDesignBuilder
            .withLayoutWidth(.fixed(width: design.defaultFunctionalButtonWidth))
            .withForegroungColor(Colors.keyboardButtonMinor)
            .withHighlightedForegroundColor(Colors.keyboardButtonMain)
            .build()

        var thirdRowItems: [RowItem] = []
        thirdRowItems.append(.caseChangeButton(caseChangeButtonViewModel, functionalButtonDesign))
        thirdRowItems.append(
            .nestedRow(
                .init(
                    items: thirdRowLetterItems,
                    style: .fill(spacing: design.letterSpacing)
                )
            )
        )
        thirdRowItems.append(.button(backspaceViewModel, functionalButtonDesign))

        var fourthRowItems: [KeyboardViewModel.RowItem] = []
        let spaceButtonViewModel = LatinSpaceKeyboardButtonViewModel()
        let spaceButtonDesign = buttonDesignBuilder
            .withLabelFont(UIFont.systemFont(ofSize: 16.0, weight: .regular))
            .withLayoutWidth(.fixed(width: floor(design.containerWidth - design.letterSpacing) * 3 / 4))
            .withForegroungColor(Colors.keyboardButtonMain)
            .withHighlightedForegroundColor(Colors.keyboardButtonMinor)
            .build()
        fourthRowItems.append(.button(spaceButtonViewModel, spaceButtonDesign))
        let returnButtonViewModel = LatinReturnKeyboardButtonViewModel()
        let returnButtonDesign = buttonDesignBuilder
            .withLayoutWidth(.fixed(width: floor(design.containerWidth - design.letterSpacing) * 1 / 4))
            .withForegroungColor(Colors.keyboardButtonMinor)
            .withHighlightedForegroundColor(Colors.keyboardButtonMain)
            .build()
        fourthRowItems.append(.button(returnButtonViewModel, returnButtonDesign))

        let additionalSymbolViewModels: [KeyboardButtonViewModelProtocol] = [
            spaceButtonViewModel,
            returnButtonViewModel
        ]
        additionalSymbolViewModels.forEach { viewModel in
            viewModel.didTapEvent.subscribe(symbolSumbitEvent) { [weak symbolSumbitEvent] content in
                switch content {
                case let .text(text, _):
                    symbolSumbitEvent?.onNext(text)

                default: break
                }
            }
        }

        let thirdRowEmptySpace: CGFloat = design.containerWidth
            - (CGFloat(thirdRowLetterItems.count) * design.letterWidth)
            - (CGFloat(thirdRowLetterItems.count - 1) * design.letterSpacing)
            - (2.0 * design.defaultFunctionalButtonWidth)
        super.init(
            rows: [
                .init(items: firstRowLetterItems, style: .fillEqually(spacing: design.letterSpacing)),
                .init(items: secondRowLetterItems, style: .fillEqually(spacing: design.letterSpacing)),
                .init(items: thirdRowItems, style: .fill(spacing: floor(thirdRowEmptySpace / 2))),
                .init(items: fourthRowItems, style: .fill(spacing: design.letterSpacing))
            ],
            design: design
        )
    }
}

extension LatinAlphabetQwertyKeyboardViewModel {

    public static func `default`() -> LatinAlphabetQwertyKeyboardViewModel {
        let letterSpacing: CGFloat = 6
        let edgeInsets: UIEdgeInsets = .init(
            top: 10,
            left: 3,
            bottom: 3,
            right: 3
        )
        let containerWidth: CGFloat = LatinAlphabetQwertyKeyboardViewModel.containerWidth(
            horizontalInsetsSum: edgeInsets.horizontalSum
        )
        let letterWidth: CGFloat = LatinAlphabetQwertyKeyboardViewModel.lettersWidth(
            containerWidth: containerWidth,
            letterSpacing: letterSpacing
        )
        let rowSpacing: CGFloat = 11
        let touchOutset = UIEdgeInsets(vertical: rowSpacing / 2, horizontal: letterSpacing / 2)
        return LatinAlphabetQwertyKeyboardViewModel(
            design: .init(
                containerWidth: containerWidth,
                defaultFunctionalButtonWidth: 44,
                letterWidth: letterWidth,
                letterSpacing: letterSpacing,
                rowSpacing: rowSpacing,
                edgeInsets: edgeInsets,
                defaultButtonDesign: .default(fixedWidth: letterWidth, touchOutset: touchOutset)
            )
        )
    }
}
