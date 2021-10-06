//
//  FontSourceModel.swift
//  Fontastic
//
//  Created by Timofey Surkov on 25.09.2021.
//

import Foundation

public struct FontSourceModel {

    public let name: String
    public let resourceType: FontResourceType

    public init(
        name: String,
        resourceType: FontResourceType
    ) {
        self.name = name
        self.resourceType = resourceType
    }
}

extension FontSourceModel {

    public static let akzidenzGroteskProBold = FontSourceModel(
        name: "Akzindenz Grotesk Pro Bold",
        resourceType: .bundled(fileName: "akzidenzgroteskpro-bold")
    )
}
