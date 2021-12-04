//
//  LinearGradient.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 04.12.2021.
//

import UIKit

public struct LinearGradient {

    public let direction: CGPoint
    public let locations: [Double]
    public let colors: [UIColor]

    public init(
        direction: CGPoint,
        locations: [Double],
        colors: [UIColor]
    ) {
        self.direction = direction
        self.locations = locations
        self.colors = colors
    }
}
