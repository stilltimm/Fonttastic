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
    fileprivate static func lettersWidth(horizontalInsetsSum: CGFloat, letterSpacing: CGFloat) -> CGFloat {
        let boundingWidth = UIScreen.main.bounds.width - horizontalInsetsSum
        let widthWithoutSpacing = boundingWidth - CGFloat(firstRowLetters.count - 1) * letterSpacing
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
        let firstRowItems = lettersRowItems[0]
        let secondRowItems = lettersRowItems[1]
        var thirdRowItems = lettersRowItems[2]

        // Functional buttons setup

        let caseChangeButtonViewModel = CaseChangeKeyboardButtonViewModel(
            capitalizationSource: isCapitalizedSourceEvent,
            textInsertedSource: symbolSumbitEvent
        )

        let backspaceViewModel = BackspaceKeyboardButtonViewModel(shouldDeleteSymbolEvent: shouldDeleteSymbolEvent)

        let buttonDesignBuilder = KeyboardButtonDesignBuilder(design.defaultButtonDesign)
        let functionalButtonDesign = buttonDesignBuilder
            .withLayoutWidth(.intrinsic(spacing: 6))
            .withForegroungColor(Colors.keyboardButtonMinor)
            .withHighlightedForegroundColor(Colors.keyboardButtonMain)
            .build()
        
        thirdRowItems.insert(.caseChangeButton(caseChangeButtonViewModel, functionalButtonDesign), at: 0)
        thirdRowItems.append(.button(backspaceViewModel, functionalButtonDesign))

//        var fourthRowItems: [KeyboardViewModel.RowItem] = []
//        let spaceButtonViewModel = LatinSpaceKeyboardButtonViewModel()
//        let
//        fourthRowItems.append(.button(<#T##KeyboardButtonViewModelProtocol#>, <#T##KeyboardButtonDesign#>))

        super.init(
            rows: [
                .init(items: firstRowItems, style: .fullWidth(spacing: design.letterSpacing)),
                .init(items: secondRowItems, style: .fullWidth(spacing: design.letterSpacing)),
                .init(items: thirdRowItems, style: .fullWidth(spacing: design.letterSpacing)),
//                .init(items: fourthRowItems, style: .equallySpaced)
            ],
            design: design
        )
    }
}

extension LatinAlphabetQwertyKeyboardViewModel {

    public static func `default`() -> LatinAlphabetQwertyKeyboardViewModel {
        let letterSpacing: CGFloat = 6
        let edgeInsets: UIEdgeInsets = .init(
            vertical: 3 / UIScreen.main.scale,
            horizontal: 3 / UIScreen.main.scale
        )
        let letterWidth: CGFloat = LatinAlphabetQwertyKeyboardViewModel.lettersWidth(
            horizontalInsetsSum: edgeInsets.horizontalSum,
            letterSpacing: letterSpacing
        )
        return LatinAlphabetQwertyKeyboardViewModel(
            design: .init(
                letterSpacing: letterSpacing,
                rowSpacing: 11,
                edgeInsets: edgeInsets,
                defaultButtonDesign: .init(
                    layoutWidth: .fixed(width: letterWidth),
                    layoutHeight: 44,
                    backgroundColor: Colors.keyboardButtonShadow,
                    foregroundColor: .white,
                    highlightedForegroundColor: Colors.keyboardButtonMainHighlighted,
                    shadowSize: 2.0 / UIScreen.main.scale,
                    cornerRadius: 5.0,
                    labelFont: UIFont.systemFont(ofSize: 25, weight: .light),
                    iconSize: .init(width: 24.0, height: 24.0)
                )
            )
        )
    }
}
