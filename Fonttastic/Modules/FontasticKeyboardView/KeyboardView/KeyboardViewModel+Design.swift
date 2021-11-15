//
//  KeyboardViewModel+Design.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 09.11.2021.
//

import Foundation
import UIKit

extension KeyboardViewModel.Design {

    public static func `default`(largestSymbolRowCount: Int) -> KeyboardViewModel.Design {
        let letterSpacing: CGFloat = 6
        let rowSpacing: CGFloat = 11
        let edgeInsets: UIEdgeInsets = .init(
            top: 10,
            left: 3,
            bottom: 3,
            right: 3
        )

        let containerWidth: CGFloat = UIScreen.main.portraitWidth - edgeInsets.horizontalSum
        let widthWithoutSpacing = containerWidth - CGFloat(largestSymbolRowCount - 1) * letterSpacing
        let letterWidth: CGFloat = floor(floor(widthWithoutSpacing) / CGFloat(largestSymbolRowCount))
        let touchOutset = UIEdgeInsets(vertical: rowSpacing / 2, horizontal: letterSpacing / 2)

        return KeyboardViewModel.Design(
            containerWidth: containerWidth,
            defaultFunctionalButtonWidth: 44,
            letterWidth: letterWidth,
            letterSpacing: letterSpacing,
            rowSpacing: rowSpacing,
            edgeInsets: edgeInsets,
            defaultButtonDesign: .default(fixedWidth: letterWidth, touchOutset: touchOutset)
        )
    }
}
