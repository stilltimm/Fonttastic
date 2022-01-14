//
//  FontListBannerType.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public enum FontListBannerType: String {

    case keyboardSetupBanner
    case subscriptionBanner

    // MARK: - Instance Properties

    public var localizedDescription: String {
        switch self {
        case .keyboardSetupBanner:
            return FonttasticToolsStrings.FontListCollection.BannerTitle.keyboardInstall

        case .subscriptionBanner:
            return FonttasticToolsStrings.FontListCollection.BannerTitle.subscriptionPurchase
        }
    }

    // MARK: - Initializers

    public init?(appStatus: AppStatus) {
        switch (appStatus.keyboardInstallationState, appStatus.subscriptionState) {
        case (.notInstalled, _):
            self = .keyboardSetupBanner

        case (_, .noSubscription), (_, .hasInactiveSubscription):
            self = .subscriptionBanner

        default:
            return nil
        }
    }
}
