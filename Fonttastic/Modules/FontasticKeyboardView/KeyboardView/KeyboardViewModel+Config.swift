//
//  KeyboardViewModel+Config.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 09.11.2021.
//

import Foundation
import FonttasticTools

extension KeyboardViewModel.Config {

    // MARK: - Internal Type Properties

    static let latin: KeyboardViewModel.Config = {
        let firstRowLetters: [(String, String)] = [
            ("q", "Q"),
            ("w", "W"),
            ("e", "E"),
            ("r", "R"),
            ("t", "T"),
            ("y", "Y"),
            ("u", "U"),
            ("i", "I"),
            ("o", "O"),
            ("p", "P")
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
            ("l", "L")
        ]
        let thirdRowLetters: [(String, String)] = [
            ("z", "Z"),
            ("x", "X"),
            ("c", "C"),
            ("v", "V"),
            ("b", "B"),
            ("n", "N"),
            ("m", "M")
        ]

        let firstRowSources = firstRowLetters
            .map { FontSymbolSourceModel.capitalizableSymbol(lowercase: $0.0, uppercase: $0.1) }
        let secondRowSources = secondRowLetters
            .map { FontSymbolSourceModel.capitalizableSymbol(lowercase: $0.0, uppercase: $0.1) }
        let thirdRowSources = thirdRowLetters
            .map { FontSymbolSourceModel.capitalizableSymbol(lowercase: $0.0, uppercase: $0.1) }

        return KeyboardViewModel.Config(
            firstRowSources: firstRowSources,
            secondRowSources: secondRowSources,
            thirdRowSources: thirdRowSources,
            keyboardType: .language(.latin)
        )
    }()

    static let cyrillic: KeyboardViewModel.Config = {
        let firstRowLetters: [(String, String)] = [
            ("й", "Й"),
            ("ц", "Ц"),
            ("у", "У"),
            ("к", "К"),
            ("е", "Е"),
            ("н", "Н"),
            ("г", "Г"),
            ("ш", "Ш"),
            ("щ", "Щ"),
            ("з", "З"),
            ("х", "Х")
        ]
        let secondRowLetters: [(String, String)] = [
            ("ф", "Ф"),
            ("ы", "Ы"),
            ("в", "В"),
            ("а", "А"),
            ("п", "П"),
            ("р", "Р"),
            ("о", "О"),
            ("л", "Л"),
            ("д", "Д"),
            ("ж", "Ж"),
            ("э", "Э")
        ]
        let thirdRowLetters: [(String, String)] = [
            ("я", "Я"),
            ("ч", "Ч"),
            ("с", "С"),
            ("м", "М"),
            ("и", "И"),
            ("т", "Т"),
            ("ь", "Ь"),
            ("б", "Б"),
            ("ю", "Ю")
        ]

        let firstRowSources = firstRowLetters
            .map { FontSymbolSourceModel.capitalizableSymbol(lowercase: $0.0, uppercase: $0.1) }
        let secondRowSources = secondRowLetters
            .map { FontSymbolSourceModel.capitalizableSymbol(lowercase: $0.0, uppercase: $0.1) }
        let thirdRowSources = thirdRowLetters
            .map { FontSymbolSourceModel.capitalizableSymbol(lowercase: $0.0, uppercase: $0.1) }

        return KeyboardViewModel.Config(
            firstRowSources: firstRowSources,
            secondRowSources: secondRowSources,
            thirdRowSources: thirdRowSources,
            keyboardType: .language(.cyrillic)
        )
    }()

    static let punctuationDefault: KeyboardViewModel.Config = {
        let firstRowSymbols: [String] = [
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "0"
        ]
        let secondRowSymbols: [String] = [
            "-",
            "/",
            ":",
            ";",
            "(",
            ")",
            "₽",
            "&",
            "@",
            "\""
        ]
        let thirdRowSymbols: [String] = [
            ".",
            ",",
            "?",
            "!",
            "'"
        ]

        let firstRowSources = firstRowSymbols
            .map { FontSymbolSourceModel.symbol($0) }
        let secondRowSources = secondRowSymbols
            .map { FontSymbolSourceModel.symbol($0) }
        let thirdRowSources = thirdRowSymbols
            .map { FontSymbolSourceModel.symbol($0) }

        return KeyboardViewModel.Config(
            firstRowSources: firstRowSources,
            secondRowSources: secondRowSources,
            thirdRowSources: thirdRowSources,
            keyboardType: .punctuation(.default)
        )
    }()

    static let punctuationAlternative: KeyboardViewModel.Config = {
        let firstRowSymbols: [String] = [
            "[",
            "]",
            "{",
            "}",
            "#",
            "%",
            "^",
            "*",
            "+",
            "="
        ]
        let secondRowSymbols: [String] = [
            "_",
            "\\",
            "|",
            "~",
            "<",
            ">",
            "$",
            "€",
            "£",
            "·"
        ]
        let thirdRowSymbols: [String] = [
            ".",
            ",",
            "?",
            "!",
            "'"
        ]

        let firstRowSources = firstRowSymbols
            .map { FontSymbolSourceModel.symbol($0) }
        let secondRowSources = secondRowSymbols
            .map { FontSymbolSourceModel.symbol($0) }
        let thirdRowSources = thirdRowSymbols
            .map { FontSymbolSourceModel.symbol($0) }

        return KeyboardViewModel.Config(
            firstRowSources: firstRowSources,
            secondRowSources: secondRowSources,
            thirdRowSources: thirdRowSources,
            keyboardType: .punctuation(.alternative)
        )
    }()

    // MARK: - Internal Type Methods

    static func `default`(for keyboardType: KeyboardType) -> KeyboardViewModel.Config {
        switch keyboardType {
        case let .language(language):
            switch language {
            case .latin:
                return KeyboardViewModel.Config.latin

            case .cyrillic:
                return KeyboardViewModel.Config.cyrillic
            }

        case let .punctuation(punctuationSet):
            switch punctuationSet {
            case .default:
                return KeyboardViewModel.Config.punctuationDefault

            case .alternative:
                return KeyboardViewModel.Config.punctuationAlternative
            }
        }
    }
}
