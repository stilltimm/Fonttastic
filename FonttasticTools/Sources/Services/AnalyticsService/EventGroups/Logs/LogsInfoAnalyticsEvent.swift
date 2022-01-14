//
//  LogsInfoAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 22.12.2021.
//  Copyright © 2021 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct LogsInfoAnalyticsEvent: AnalyticsEvent {

    // MARK: - Type Properties

    public static var group: AnalyticsEventGroup { .logs }
    public static var name: String { "info" }

    // MARK: - Instance Properties

    public let title: String
    public let message: String
    public let location: String
    public let dateString: String

    // MARK: - Initializers

    public init(
        title: String,
        message: String,
        location: String,
        dateString: String
    ) {
        self.title = title
        self.message = message
        self.location = location
        self.dateString = dateString
    }

    // MARK: - Instance Methods

    public var parametersDictionary: [String: AnyHashable]? {
        return [
            "title": title,
            "message": message,
            "location": location,
            "date": dateString
        ]
    }
}
