//
//  UIEdgeInsets+Utils.swift
//  Fontastic
//
//  Created by Timofey Surkov on 26.09.2021.
//

import UIKit

extension UIEdgeInsets {

    var horizontalSum: CGFloat { left + right }
    var verticalSum: CGFloat { top + bottom }

    init(vertical: CGFloat, horizontal: CGFloat) {
        self.init(
            top: vertical,
            left: horizontal,
            bottom: vertical,
            right: horizontal
        )
    }
}
