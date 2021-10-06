//
//  FontFactory.swift
//  Fontastic
//
//  Created by Timofey Surkov on 23.09.2021.
//

import Foundation
import UIKit

public class UIFontFactory {

    public static func makeFont(from fontModel: FontModel, withSize size: CGFloat) -> UIFont? {
        return makeFont(withName: fontModel.name, withSize: size)
    }

    public static func makeFont(withName name: String, withSize size: CGFloat) -> UIFont? {
        let descriptor = UIFontDescriptor(name: name, size: size)
        return UIFont(descriptor: descriptor, size: size)
    }
}
