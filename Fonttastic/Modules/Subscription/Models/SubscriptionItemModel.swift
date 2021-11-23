//
//  SubscriptionItemModel.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 21.11.2021.
//

import Foundation

struct SubscriptionItemModel {

    let identifier: String
    let title: String
    let price: Price
    let strikethroughPrice: Price?
}

struct Currency {

    let locale: Locale
}

extension Currency {

    static let rub = Currency(locale: Locale(identifier: "ru_RU"))
    static let dollar = Currency(locale: Locale(identifier: "en_US_POSIX"))
}

struct Price {

    let value: Decimal
    let currency: Currency
}

class PriceFormatter {

    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .autoupdatingCurrent
        return formatter
    }()

    func string(from price: Price) -> String {
        numberFormatter.locale = price.currency.locale
        return numberFormatter.string(from: price.value as NSDecimalNumber) ?? "-"
    }
}
