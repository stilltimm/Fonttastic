//
//  KeyboardView.swift
//  FontasticKeyboard
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import Cartography
import FonttasticTools

class KeyboardView: UIView {

    // MARK: - Nested Types

    typealias ViewModel = KeyboardViewModel

    // MARK: - Internal Instance Methods

    var design: ViewModel.Design { viewModel.design }
    var keyboardType: KeyboardType { viewModel.config.keyboardType }

    // MARK: - Private Instance Properties

    private let viewModel: ViewModel

    // MARK: - Initializers

    init(viewModel: ViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Unimplemented")
    }

    // MARK: - Instance Methods

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        setupLayout()
    }

    private func setupLayout() {
        let rowsContainerView = UIView()
        addSubview(rowsContainerView)
        constrain(self, rowsContainerView) { view, containerView in
            containerView.left == view.left + design.edgeInsets.left
            containerView.right == view.right - design.edgeInsets.right
            containerView.top >= view.top + design.edgeInsets.top
            containerView.bottom <= view.bottom - design.edgeInsets.bottom
            containerView.centerY == view.centerY
        }

        let rowViews = viewModel.rows.map { makeRowView($0) }
        rowViews.forEach { rowsContainerView.addSubview($0) }

        for (i, rowView) in rowViews.enumerated() {

            // MARK: - Vertical Cosntraints

            // NOTE: pin first row to container top
            if i == 0 {
                constrain(rowsContainerView, rowView) { containerView, rowView in
                    rowView.top == containerView.top
                }
            }

            // NOTE: pin row to to prevRow bottom and make height equal
            if let prevRowView = rowViews[safe: i - 1] {
                constrain(rowView, prevRowView) { rowView, prevRowView in
                    rowView.top == prevRowView.bottom + design.rowSpacing
                    rowView.height == prevRowView.height
                }
            }

            // NOTE: pin last row to container bottom
            if i == rowViews.count - 1 {
                constrain(rowsContainerView, rowView) { containerView, rowView in
                    rowView.bottom == containerView.bottom
                }
            }

            // MARK: - Horizontal Constraints

            constrain(rowView, rowsContainerView) { rowView, rowContainer in
                rowView.centerX == rowContainer.centerX
            }
        }
    }

    private func makeRowView(_ row: ViewModel.Row) -> UIView {
        let rowView = UIView()

        let rowItemViews = row.items.map { makeRowItemView($0) }
        rowItemViews.forEach { rowView.addSubview($0) }

        for (i, rowItemView) in rowItemViews.enumerated() {

            // MARK: - Horizontal Constraints

            // NOTE: pin first row item to row left
            if i == 0 {
                constrain(rowItemView, rowView) { rowItemView, rowView in
                    rowItemView.left == rowView.left
                }
            }

            // NOTE: row item left to previous row item right + spacing
            if let prevRowItemView = rowItemViews[safe: i - 1] {
                constrain(rowItemView, prevRowItemView) { rowItemView, prevRowItemView in
                    rowItemView.left == prevRowItemView.right + row.spacing
                }
            }

            // NOTE: pin last row item to row right
            if i == rowItemViews.count - 1 {
                constrain(rowItemView, rowView) { rowItemView, rowView in
                    rowItemView.right == rowView.right
                }
            }

            // MARK: - Vertical Cosntraints

            constrain(rowItemView, rowView) { rowItemView, rowView in
                rowView.height >= rowItemView.height
                rowItemView.centerY == rowView.centerY
            }
        }

        return rowView
    }

    private func makeRowItemView(_ rowItem: ViewModel.RowItem) -> UIView {
        switch rowItem {
        case let .nestedRow(row):
            return makeRowView(row)

        case let .button(viewModel, design):
            return KeyboardButton(viewModel: viewModel, design: design)

        case let .caseChangeButton(viewModel, design):
            return CaseChangeKeyboardButton(caseChangeViewModel: viewModel, design: design)
        }
    }
}
