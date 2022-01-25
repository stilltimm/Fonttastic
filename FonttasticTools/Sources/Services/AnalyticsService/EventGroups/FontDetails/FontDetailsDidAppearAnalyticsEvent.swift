//
//  FontDetailsDidAppearAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct FontDetailsDidAppearAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .fontDetails }
    public static var name: String { "didAppear" }

    // MARK: - Instance Properties

    public let fontModel: FontModel

    // MARK: - Initializers

    public init(fontModel: FontModel) {
        self.fontModel = fontModel
    }

    // MARK: - Instance Methods

    public func makeParametersDictionary() -> [String: AnyHashable]? {
        return [
            "fontName": fontModel.name,
            "fontDisplayName": fontModel.displayName,
            "fontType": fontModel.resourceType.typeName,
            "fontTypeDebugDescription": fontModel.resourceType.debugDescription
        ]
    }
}
