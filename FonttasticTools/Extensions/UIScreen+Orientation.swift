//
//  UIScreen+Orientation.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 13.10.2021.
//

import UIKit

extension UIScreen {

    public var isPortrait: Bool { bounds.width < bounds.height }
}
