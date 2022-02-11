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

    func makeParametersDictionary() -> [String: AnyHashable]?
}

public extension AnalyticsEvent {

    func makeAnalyticsEventType() -> String {
        return "\(Self.group.name).\(Self.name)"
    }

    func makeParametersDictionary() -> [String: AnyHashable]? {
        return nil
    }
}
