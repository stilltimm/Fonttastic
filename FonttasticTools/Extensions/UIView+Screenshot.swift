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

        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.clear(CGRect(origin: .zero, size: self.bounds.size))

        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}
