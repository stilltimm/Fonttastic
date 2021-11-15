//
//  KeyboardType.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 09.11.2021.
//

import Foundation

enum KeyboardType: Equatable, CaseIterable {

    case language(Language)
    case punctuation(PunctuationSet)

    // MARK: - Nested Types

    enum Language: Equatable, CaseIterable {
        case latin
        case cyrillic
    }

    enum PunctuationSet: Equatable, CaseIterable {
        case `default`
        case alternative
    }

    // MARK: - Type Properties

    static var allCases: [KeyboardType] = [
        .language(.latin),
        .language(.cyrillic),
        .punctuation(.default),
        .punctuation(.alternative)
    ]
}

extension KeyboardType.PunctuationSet {

    var next: KeyboardType.PunctuationSet {
        switch self {
        case .default:
            return .alternative

        case .alternative:
            return .default
        }
    }
}

extension KeyboardType.Language {

    var next: KeyboardType.Language {
        switch self {
        case .latin:
            return .cyrillic

        case .cyrillic:
            return .latin
        }
    }
}
