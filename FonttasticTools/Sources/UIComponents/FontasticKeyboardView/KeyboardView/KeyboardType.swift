//
//  KeyboardType.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 09.11.2021.
//

import Foundation

public enum KeyboardType: Equatable, CaseIterable {

    case language(Language)
    case punctuation(PunctuationSet)

    // MARK: - Nested Types

    public enum Language: Int, CaseIterable {
        case latin
        case cyrillic
    }

    public enum PunctuationSet: Int, CaseIterable {
        case `default`
        case alternative
    }

    // MARK: - Type Properties

    public static var allCases: [KeyboardType] = [
        .language(.latin),
        .language(.cyrillic),
        .punctuation(.default),
        .punctuation(.alternative)
    ]
}

extension KeyboardType.PunctuationSet {

    public var next: KeyboardType.PunctuationSet {
        switch self {
        case .default:
            return .alternative

        case .alternative:
            return .default
        }
    }
}

extension KeyboardType.Language {

    public var next: KeyboardType.Language {
        switch self {
        case .latin:
            return .cyrillic

        case .cyrillic:
            return .latin
        }
    }
}
