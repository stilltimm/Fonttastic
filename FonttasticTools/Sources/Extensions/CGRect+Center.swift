//
//  CGRect+Center.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 08.12.2021.
//

import UIKit

extension CGRect {

    public var center: CGPoint {
        return CGPoint(
            x: origin.x + size.width / 2,
            y: origin.y + size.height / 2
        )
    }
}
