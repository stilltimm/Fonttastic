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
        case nestedRow(Row)
    }

    class Row {
        let items: [RowItem]
        let spacing: CGFloat

        init(items: [RowItem], spacing: CGFloat) {
            self.items = items
            self.spacing = spacing
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
