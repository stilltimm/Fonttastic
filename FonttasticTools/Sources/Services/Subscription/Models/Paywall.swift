//
//  Paywall.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 15.12.2021.
//

import Foundation
import RevenueCat

public struct Paywall {

    // MARK: - Private Type Properties

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()

    // MARK: - Public Instance Properties

    public let headerTitle: String
    public let headerSubtitle: String
    public let buttonTitle: String
    public let items: [PaywallItem]
    public let initiallySelectedItem: PaywallItem?

    // MARK: - Internal Instance Properties

    let offeringIdentifier: String
    let isTrial: Bool

    // MARK: - Initializers

    init(offering: RevenueCat.Offering, isTrial: Bool) {
        self.offeringIdentifier = offering.identifier
        self.isTrial = isTrial

        if isTrial {
            self.headerTitle = FonttasticToolsStrings.Subscription.Header.Title.trial
            self.buttonTitle = FonttasticToolsStrings.Subscription.Button.Title.trial
        } else {
            self.headerTitle = FonttasticToolsStrings.Subscription.Header.Title.default
            self.buttonTitle = FonttasticToolsStrings.Subscription.Button.Title.default
        }
        self.headerSubtitle = FonttasticToolsStrings.Subscription.Header.subtitle

        var expectedMonthlyPriceString: String?
        if let weeklyOffering = offering.weekly {
            let expectedMonthlyPrice: NSDecimalNumber = weeklyOffering.product.price
                .multiplying(by: NSDecimalNumber(value: Constants.numberOfWeeksPerMonth))
                .rounding(accordingToBehavior: NSDecimalNumber.defaultBehavior)
            Self.numberFormatter.locale = weeklyOffering.product.priceLocale
            expectedMonthlyPriceString = Self.numberFormatter.string(from: expectedMonthlyPrice)
        }

        var initiallySelectedItem: PaywallItem?
        self.items = offering.availablePackages
            .sorted { $0.packageType.displayPriority < $1.packageType.displayPriority }
            .map { package -> PaywallItem in
                var strikethroughPrice: String?
                if package.packageType == .monthly, let expectedMonthlyPriceString = expectedMonthlyPriceString {
                    strikethroughPrice = expectedMonthlyPriceString
                }
                var subtitle: String?
                if isTrial {
                    subtitle = FonttasticToolsStrings.Subscription.Item.Subtitle.Trial.Days._3
                }

                let paywallItem = PaywallItem(
                    package: package,
                    subtitle: subtitle,
                    strikethroughPrice: strikethroughPrice
                )

                if package.packageType == .monthly {
                    initiallySelectedItem = paywallItem
                }

                return paywallItem
            }

        if initiallySelectedItem == nil {
            initiallySelectedItem = items.last
        }
        self.initiallySelectedItem = initiallySelectedItem
    }
}

private enum Constants {

    static let numberOfWeeksPerMonth: Int = 4
}
