//
//  NonSpecificLogError.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 22.12.2021.
//  Copyright © 2021 com.romandegtyarev. All rights reserved.
//

import Foundation

public struct NonSpecificLogError: Error, CustomNSError {

    public static var errorDomain: String { "com.fonttastic.non-specific-log-error" }

    public var errorCode: Int { -1 }
    public let errorUserInfo: [String: Any]

    public init(
        title: String,
        message: String,
        location: String
    ) {
        var userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: title,
            NSHelpAnchorErrorKey: location
        ]

        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedMessage.isEmpty {
            userInfo[NSLocalizedFailureReasonErrorKey] = trimmedMessage
        }

        self.errorUserInfo = userInfo
    }
}
