//
//  KeyboardViewModel.swift
//  FontasticKeyboard
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import FonttasticTools

class KeyboardViewModel {

    // MARK: - Nested Types

    enum RowItem {
        case caseChangeButton(CaseChangeKeyboardButtonViewModel, KeyboardButtonDesign)
        case button(KeyboardButtonViewModelProtocol, KeyboardButtonDesign)
        case nestedSelfSizingRow(SelfSizingRow)
    }

    enum RowWidthStyle {
        /// Does not positions itself horizontally, because this row width stretches to fill all items with their widths + spacing
        case selfSizingItems(spacing: CGFloat)

        /// Stretches to full width of container and fills the gaps between items with equal spacing
        case fillWithEqualSpacing
    }

    class Row {
        let items: [RowItem]
        let style: RowWidthStyle

        init(items: [RowItem], style: RowWidthStyle) {
            self.items = items
            self.style = style
        }
    }

    class SelfSizingRow: Row {

        init(items: [RowItem], spacing: CGFloat) {
            super.init(items: items, style: .selfSizingItems(spacing: spacing))
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
