//
//  AlphabetType.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 17.10.2021.
//

import Foundation
import UIKit

enum AlphabetType: CaseIterable {

    case latinAllCaps
    case latinCapsAndSmall
    case cyrillicAllCaps
    case cyrillicCapsAndSmall
    case cyrillicAllCapsWithESoft
    case cyrillicCapsAndSmallWithESoft

    var title: String {
        switch self {
        case .latinAllCaps:
            return "Latin only Caps"

        case .latinCapsAndSmall:
            return "Latin Caps and Small"

        case .cyrillicAllCaps:
            return "Cyrillic only Caps"

        case .cyrillicCapsAndSmall:
            return "Cyrillic Caps and Small"

        case .cyrillicAllCapsWithESoft:
            return "Cyrillic only Caps (with soft sign)"

        case .cyrillicCapsAndSmallWithESoft:
            return "Cyrillic Caps and Small (with soft sign)"
        }
    }

    var imageTipText: String {
        switch self {
        case .latinAllCaps:
            return "26 caps letters in squares aligned in a row"

        case .latinCapsAndSmall:
            return "26 caps letters and 26 small letters (totally 52) in squares aligned in a row"

        case .cyrillicAllCaps:
            return "32 caps letters in squares aligned in a row"

        case .cyrillicCapsAndSmall:
            return "32 caps letters and 32 small letters (totally 64) in squares aligned in a row"

        case .cyrillicAllCapsWithESoft:
            return "33 caps letters in squares aligned in a row"

        case .cyrillicCapsAndSmallWithESoft:
            return "33 caps letters and 33 small letters (totally 66) in squares aligned in a row"
        }
    }

    var imageRatio: CGFloat {
        switch self {
        case .latinAllCaps:
            return 26.0 / 1.0

        case .latinCapsAndSmall:
            return 26.0 * 2.0 / 1.0

        case .cyrillicAllCaps:
            return 32.0 / 1.0

        case .cyrillicCapsAndSmall:
            return 32.0 * 2.0 / 1.0

        case .cyrillicAllCapsWithESoft:
            return 33.0 / 1.0

        case .cyrillicCapsAndSmallWithESoft:
            return 33.0 * 2.0 / 1.0
        }
    }

    var orderedLetters: [LetterType] {
        switch self {
        case .latinAllCaps:
            return Constants.latinCapsLetters

        case .latinCapsAndSmall:
            return Constants.latinCapsLetters + Constants.latinCapsLetters.map { $0.lowercased() }

        case .cyrillicAllCaps:
            return Constants.cyrillicCapsLetters

        case .cyrillicCapsAndSmall:
            return Constants.cyrillicCapsLetters + Constants.cyrillicCapsLetters.map { $0.lowercased() }

        case .cyrillicAllCapsWithESoft:
            return Constants.cyrillicCapsWithSoftSignLetters

        case .cyrillicCapsAndSmallWithESoft:
            let uppercase = Constants.cyrillicCapsWithSoftSignLetters
            let lowercase = uppercase.map { $0.lowercased() }
            return uppercase + lowercase
        }
    }
}

private enum Constants {

    static let latinCapsLetters: [LetterType] = [
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
        "W", "X", "Y", "Z"
    ]

    static let cyrillicCapsWithSoftSignLetters: [LetterType] = [
        "А", "Б", "В", "Г", "Д", "Е", cyrillicSoftSign, "Ж", "З", "И", "Й", "К", "Л", "М", "Н", "О", "П", "Р", "С", "Т",
        "У", "Ф", "Х", "Ц", "Ч", "Ш", "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", "Я"
    ]

    static let cyrillicCapsLetters: [LetterType] = {
        var result = cyrillicCapsWithSoftSignLetters
        if let indexOfSoftSign = result.firstIndex(of: cyrillicSoftSign) {
            result.remove(at: indexOfSoftSign)
        }
        return result
    }()

    static let cyrillicSoftSign: LetterType = "Ё"
}
