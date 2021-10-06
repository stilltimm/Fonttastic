//
//  UIView+Screenshot.swift
//  FontasticTools
//
//  Created by Timofey Surkov on 29.09.2021.
//

import UIKit

extension UIView {

    public func takeScreenshot(backgroundColor: UIColor? = nil) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

        if let backgroundColor = backgroundColor {
            backgroundColor.setFill()
            UIRectFill(self.bounds)
        }
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}
