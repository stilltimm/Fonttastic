//
//  FontModel.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import Foundation

public struct FontModel: Hashable {

    public let name: String
    public let displayName: String
    public let resourceType: FontResourceType
    public let status: FontStatus

    public init(
        name: String,
        displayName: String,
        resourceType: FontResourceType,
        status: FontStatus
    ) {
        self.name = name
        self.displayName = displayName
        self.resourceType = resourceType
        self.status = status
    }
}

extension FontModel {

    public var sourceModel: FontSourceModel {
        .init(name: name, resourceType: resourceType)
    }
}
