//
//  FontFactory.swift
//  Fontastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import Foundation
import UIKit

class FontFactory {

    static func makeFont(from fontModel: FontModel, withSize size: CGFloat) -> UIFont? {
        return UIFont(name: fontModel.name, size: size)
    }
}
