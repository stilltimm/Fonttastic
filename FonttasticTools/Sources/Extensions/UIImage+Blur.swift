//
//  UIImage+Blur.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 09.01.2022.
//  Copyright © 2022 com.romandegtyarev. All rights reserved.
//

import UIKit

extension UIImage {

    public func blurImage(for rect: CGRect, radius: Double) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }

        let context = CIContext(options: nil)
        let inputImage = CIImage(cgImage: cgImage)

        guard let filter = CIFilter(name: "CIGaussianBlur") else { return nil }

        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)

        guard
            let outputImage = filter.outputImage,
            let outputCgImage = context.createCGImage(
                outputImage,
                from: CGRect(
                    origin: CGPoint(
                        x: rect.origin.x,
                        y: self.size.height - rect.maxY
                    ),
                    size: rect.size
                )
            )
        else { return nil }

        return UIImage(cgImage: outputCgImage)
    }
}
