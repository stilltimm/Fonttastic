//
//  UIScreen+Orientation.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 13.10.2021.
//

import UIKit

extension UIScreen {

    // MARK: - Nested Types

    public enum SizeClass {

        case small
        case normal
        case big
    }

    // MARK: - Instance Properties

    public var isPortrait: Bool { bounds.width < bounds.height }
    public var portraitWidth: CGFloat { isPortrait ? bounds.width : bounds.height }
    public var landscapeWidth: CGFloat { isPortrait ? bounds.height : bounds.width }

    public var sizeClass: SizeClass {
        if self.bounds.width < Constants.normalDeviceSizeThreshold {
            return .small
        } else if self.bounds.width == Constants.normalDeviceSizeThreshold {
            return .normal
        } else {
            return .big
        }
    }
}

private enum Constants {

    static let normalDeviceSizeThreshold: CGFloat = 375
}
