//
//  Strings.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 21.11.2021.
//

import Foundation
import FonttasticTools

class Strings {

    // MARK: - Private Type Properties

    private static let localizedStringBox = LocalizedStringsBox(bundle: Bundle(for: Strings.self))

    // MARK: - Subscription

    static let subscriptionNavigationItemRestoreActionTitle = localizedStringBox[
        "subscription.navigationItem.restoreActionTitle"
    ]
    static let subscriptionNavigationItemTermsActionTitle = localizedStringBox[
        "subscription.navigationItem.termsActionTitle"
    ]
    static let subscriptionHeaderTitle = localizedStringBox[
        "subscription.header.title"
    ]
    static let subscriptionHeaderSubtitle = localizedStringBox[
        "subscription.header.subtitle"
    ]
    static let subscriptionActionButtonTitle = localizedStringBox[
        "subscription.actionButton.title"
    ]
}
