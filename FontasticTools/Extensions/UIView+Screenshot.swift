//
//  UIView+Screenshot.swift
//  FontasticTools
//
//  Created by Timofey Surkov on 29.09.2021.
//

import UIKit

extension UIView {

    public func takeScreenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}
