//
//  InfoLogAnalyticsEvent.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 22.12.2021.
//  Copyright © 2021 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct InfoLogAnalyticsEvent: AnalyticsEvent {

    public static var group: AnalyticsEventGroup { .log }
    public static var name: String { "info" }

    public let title: String
    public let message: String
    public let location: String
    public let dateString: String

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

    public var parametersDictionary: [String : AnyHashable]? {
        return [
            "title": title,
            "message": message,
            "location": location,
            "date": dateString
        ]
    }
}
