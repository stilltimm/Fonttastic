//
//  PaywallItem.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 15.12.2021.
//

import Foundation
import RevenueCat

public struct PaywallItem: Hashable  {

    // MARK: - Public Instance Properties

    public let identifier: String
    public let title: String
    public let subtitle: String?
    public let price: String
    public let strikethroughPrice: String?

    // MARK: - Internal Instance Properties

    let package: RevenueCat.Package

    // MARK: - Initializers

    init(
        package: RevenueCat.Package,
        subtitle: String?,
        strikethroughPrice: String?
    ) {
        self.package = package
        self.identifier = package.identifier
        self.title = package.packageType.localizedDescription
        self.subtitle = subtitle
        self.price = package.localizedPriceString
        self.strikethroughPrice = strikethroughPrice
    }
}
