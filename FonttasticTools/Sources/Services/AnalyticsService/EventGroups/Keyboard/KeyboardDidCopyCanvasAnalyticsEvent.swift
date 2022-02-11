//
//  KeyboardDidCopyCanvasAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 14.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct KeyboardDidCopyCanvasAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .keyboard }
    public static var name: String { "didCopyCanvas" }

    // MARK: - Instance Properties

    public let canvasViewDesign: CanvasViewDesign

    // MARK: - Initializers

    public init(canvasViewDesign: CanvasViewDesign) {
        self.canvasViewDesign = canvasViewDesign
    }

    // MARK: - Instance Methods

    public func makeParametersDictionary() -> [String: AnyHashable]? {
        return [
            "fontName": canvasViewDesign.fontModel.name,
            "fontDisplayName": canvasViewDesign.fontModel.displayName,
            "fontType": canvasViewDesign.fontModel.resourceType.typeName,
            "fontTypeDebugDescription": canvasViewDesign.fontModel.resourceType.debugDescription,
            "backgroundColor": "\(canvasViewDesign.backgroundColor.hexValue)",
            "textColor": "\(canvasViewDesign.textColor.hexValue)",
            "hasBackgroundImage": canvasViewDesign.backgroundImage != nil,
            "textAlignment": canvasViewDesign.textAlignment.description
        ]
    }
}
