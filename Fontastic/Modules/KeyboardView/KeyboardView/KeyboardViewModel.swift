//
//  KeyboardViewModel.swift
//  FontasticKeyboard
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import FontasticTools

class KeyboardViewModel {

    // MARK: - Nested Types

    enum RowItem {
        case caseChangeButton(CaseChangeKeyboardButtonViewModel, KeyboardButtonDesign)
        case button(KeyboardButtonViewModelProtocol, KeyboardButtonDesign)
        case nestedRow(Row)
    }

    enum RowStyle {
        case fill(spacing: CGFloat)
        case fillEqually(spacing: CGFloat)
    }

    class Row {
        let items: [RowItem]
        let style: RowStyle

        init(items: [RowItem], style: RowStyle) {
            self.items = items
            self.style = style
        }
    }

    struct Design {
        let containerWidth: CGFloat
        let defaultFunctionalButtonWidth: CGFloat
        let letterWidth: CGFloat
        let letterSpacing: CGFloat
        let rowSpacing: CGFloat
        let edgeInsets: UIEdgeInsets
        let defaultButtonDesign: KeyboardButtonDesign
    }

    // MARK: - Instance Properties

    let rows: [Row]
    let design: Design

    // MARK: - Initializers

    init(rows: [Row], design: Design) {
        self.rows = rows
        self.design = design
    }
}
