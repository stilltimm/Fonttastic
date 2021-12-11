//
//  SubscriptionItemModel.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 09.12.2021.
//

import Foundation
import StoreKit

public struct InAppPurchaseProductModel {

    // MARK: - Public Instance Properties

    public var localizedTitle: String { product.localizedTitle }
    public var localizedDescription: String { product.localizedDescription }
    public let localizedPrice: String?
    public let localizedDicount: String?

    // MARK: - Internal Instance Properties

    let product: SKProduct

    // MARK: - Private Instance Properties

    private let priceFormatter: NumberFormatter

    // MARK: - Initializers

    init(_ product: SKProduct) {
        self.product = product

        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        priceFormatter.locale = product.priceLocale
        self.priceFormatter = priceFormatter

        self.localizedPrice = priceFormatter.string(from: product.price)
        self.localizedDicount = nil // TODO: fix discount
    }
}
