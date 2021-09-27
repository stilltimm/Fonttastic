//
//  KeyboardViewModel.swift
//  FontasticKeyboard
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import FontasticTools

class KeyboardViewModel {

    // MARK: - Nested Types

    enum RowItem {
        case symbolButton(SymbolButton.ViewModel)
        case nestedRow(Row)
    }

    enum RowStyle {
        case equallySpaced
        case fullWidth(spacing: CGFloat)
    }

    class Row {
        let items: [RowItem]
        let style: RowStyle

        init(items: [RowItem], style: RowStyle) {
            self.items = items
            self.style = style
        }
    }

    struct Design {
        let letterSpacing: CGFloat
        let rowSpacing: CGFloat
        let edgeInsets: UIEdgeInsets
        let symbolDesign: SymbolButton.Design
    }

    // MARK: - Instance Properties

    let rows: [Row]
    let design: Design

    // MARK: - Initializers

    init(rows: [Row], design: Design) {
        self.rows = rows
        self.design = design
    }
}

class LatinAlphabetQwertyKeyboardViewModel: KeyboardViewModel {

    private let isCapitalizedSourceEvent: HotEvent<Bool>
    private let letterWidth: CGFloat

    init(design: Design) {
        let firstRowLetters: [(String, String)] = [
            ("q", "Q"),
            ("w", "W"),
            ("e", "E"),
            ("r", "R"),
            ("t", "T"),
            ("y", "Y"),
            ("u", "Y"),
            ("i", "Y"),
            ("o", "Y"),
            ("p", "Y"),
        ]
        let secondRowLetters: [(String, String)] = [
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
        let thirdRowLetters: [(String, String)] = [
            ("z", "Z"),
            ("x", "X"),
            ("c", "C"),
            ("v", "V"),
            ("b", "B"),
            ("n", "N"),
            ("m", "M"),
        ]

        let boundingWidth = UIScreen.main.bounds.width - design.edgeInsets.horizontalSum
        let widthWithoutSpacing = boundingWidth - CGFloat(firstRowLetters.count - 1) * design.letterSpacing
        let letterWidth = floor(floor(widthWithoutSpacing) / CGFloat(firstRowLetters.count))
        self.letterWidth = letterWidth

        let isCapitalizedSourceEvent = HotEvent<Bool>(value: false)
        self.isCapitalizedSourceEvent = isCapitalizedSourceEvent

        let lettersRows = [firstRowLetters, secondRowLetters, thirdRowLetters]
        let lettersRowItems: [[KeyboardViewModel.RowItem]] = lettersRows
            .map { row -> [KeyboardViewModel.RowItem] in
                row
                    .map { (uncapitalized, capitalized) -> KeyboardLabelButtonViewModel in
                        .capitalizableSymbol(
                            .init(
                                uncapitalizedSymbol: uncapitalized,
                                capitalizedSymbol: capitalized,
                                style: KeyboardLabelButtonStyle.fixed(width: letterWidth),
                                capitalizationSource: isCapitalizedSourceEvent
                            )
                        )
                    }
                    .map { KeyboardViewModel.RowItem.symbolButton($0) }
            }

        super.init(
            rows: [
                .init(items: lettersRowItems[0], style: .fullWidth(spacing: design.letterSpacing)),
                .init(items: lettersRowItems[1], style: .fullWidth(spacing: design.letterSpacing)),
                .init(items: lettersRowItems[2], style: .fullWidth(spacing: design.letterSpacing))
            ],
            design: design
        )
    }
}

private enum Constants {

    static let defaultSmallSpacing: CGFloat = 4.0
}
