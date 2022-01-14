//
//  FontListDidTapBannerAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct FontListDidTapBannerAnalyticsEvent: AnalyticsEvent {

    // MARK: - Nested Types

    public enum BannerType: String {
        case keyboardSetup
        case subscription
    }

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .fontList }
    public static var name: String { "didTapBanner" }

    // MARK: - Instance Properties

    public let bannerType: BannerType

    // MARK: - Initializers

    public init(bannerType: BannerType) {
        self.bannerType = bannerType
    }

    // MARK: - Instance Methods

    public func makeParametersDictionary() -> [String: AnyHashable]? {
        return [
            "bannerType": bannerType.rawValue
        ]
    }
}
