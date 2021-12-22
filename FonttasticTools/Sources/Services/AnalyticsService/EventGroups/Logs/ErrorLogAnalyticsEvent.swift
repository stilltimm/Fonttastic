//
//  ErrorLogAnalyticsEvent.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 22.12.2021.
//  Copyright © 2021 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct ErrorLogAnalyticsEvent: AnalyticsEvent {

    public static var group: AnalyticsEventGroup { .log }
    public static var name: String { "error" }

    public let title: String
    public let message: String
    public let location: String
    public let dateString: String
    public let error: Error?

    public init(
        title: String,
        message: String,
        location: String,
        dateString: String,
        error: Error?
    ) {
        self.title = title
        self.message = message
        self.location = location
        self.dateString = dateString
        self.error = error
    }

    public var parametersDictionary: [String : AnyHashable]? {
        return [
            "title": title,
            "message": message,
            "location": location,
            "date": dateString,
            "error": error.flatMap { String(describing: $0 as NSError) } ?? "None"
        ]
    }
}
