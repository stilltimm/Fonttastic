//
//  AnalyticsEvent.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 22.12.2021.
//  Copyright © 2021 com.romandegtyarev. All rights reserved.
//

import Foundation

public protocol AnalyticsEvent {

    static var group: AnalyticsEventGroup { get }
    static var name: String { get }

    var parametersDictionary: [String: AnyHashable]? { get }
}

extension AnalyticsEvent {

    public var analyticsEventType: String {
        return "\(Self.group.rawValue).\(Self.name)"
    }

    public var parametersDictionary: [String: AnyHashable]? { nil }
}
