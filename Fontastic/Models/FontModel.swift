//
//  FontModel.swift
//  Fontastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import Foundation

struct FontModel {
    
    let name: String
    let displayName: String
    let resourceType: FontResourceType
    let status: FontStatus
}

extension FontModel {

    var sourceModel: FontSourceModel {
        .init(name: name, resourceType: resourceType)
    }
}
