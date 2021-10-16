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

    private let viewModel: ViewModel
    var design: ViewModel.Design { viewModel.design }

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

        let rowsWithRowViews = viewModel.rows.map { (rowModel: $0, rowView: makeRowView($0)) }
        rowsWithRowViews.forEach { rowsContainerView.addSubview($0.rowView) }

        for (i, (rowModel, rowView)) in rowsWithRowViews.enumerated() {

            // MARK: - Vertical Cosntraints

            // NOTE: pin first row to container top
            if i == 0 {
                constrain(rowsContainerView, rowView) { containerView, rowView in
                    rowView.top == containerView.top
                }
            }

            // NOTE: pin row to to prevRow bottom and make height equal
            if let prevRowView = rowsWithRowViews[safe: i - 1]?.rowView {
                constrain(rowView, prevRowView) { rowView, prevRowView in
                    rowView.top == prevRowView.bottom + design.rowSpacing
                    rowView.height == prevRowView.height
                }
            }

            // NOTE: pin last row to container bottom
            if i == rowsWithRowViews.count - 1 {
                constrain(rowsContainerView, rowView) { containerView, rowView in
                    rowView.bottom == containerView.bottom
                }
            }

            // MARK: - Horizontal Constraints

            switch rowModel.style {
            case .fillWithEqualSpacing:
                constrain(rowView, rowsContainerView) { rowView, rowContainer in
                    rowView.left == rowContainer.left
                    rowView.right == rowContainer.right
                }

            case .selfSizingItems:
                constrain(rowView, rowsContainerView) { rowView, rowContainer in
                    rowView.centerX == rowContainer.centerX
                }
            }
        }
    }

    private func makeRowView(_ row: ViewModel.Row) -> UIView {
        let rowView = UIView()

        let rowItemsAndViews = row.items.map { (rowItem: $0, rowItemView: makeRowItemView($0)) }
        rowItemsAndViews.forEach { rowView.addSubview($0.rowItemView) }

        var fakeEqualSpacingViews = [UIView]()
        for (i, (rowItem, rowItemView)) in rowItemsAndViews.enumerated() {
            // NOTE: pin first row item to row left
            if i == 0 {
                constrain(rowItemView, rowView) { rowItemView, rowView in
                    rowItemView.left == rowView.left
                }
            }

            if let prevRowItemView = rowItemsAndViews[safe: i - 1]?.rowItemView {
                switch row.style {
                case let .selfSizingItems(spacing):
                    // NOTE: row item left to previous row item right + spacing
                    constrain(rowItemView, prevRowItemView) { rowItemView, prevRowItemView in
                        rowItemView.left == prevRowItemView.right + spacing
                    }

                case .fillWithEqualSpacing:
                    // NOTE: pin row item left to fakeView right and prev row item right to fakeView left
                    let fakeEqualSpacingView = UIView()
                    fakeEqualSpacingView.isUserInteractionEnabled = false
                    fakeEqualSpacingViews.append(fakeEqualSpacingView)
                    rowView.addSubview(fakeEqualSpacingView)
                    constrain(
                        rowItemView, prevRowItemView, fakeEqualSpacingView
                    ) { rowItemView, prevRowItemView, fakeEqualSpacingView in
                        rowItemView.left == fakeEqualSpacingView.right
                        prevRowItemView.right == fakeEqualSpacingView.left
                    }
                }
            }

            // NOTE: pin last row item to row right
            if i == rowItemsAndViews.count - 1 {
                constrain(rowItemView, rowView) { rowItemView, rowView in
                    rowItemView.right == rowView.right
                }
            }

            constrain(rowItemView, rowView) { rowItemView, rowView in
                rowView.height >= rowItemView.height
                rowItemView.centerY == rowView.centerY
            }
        }

        if !fakeEqualSpacingViews.isEmpty {
            for (i, fakeEqualSpacingView) in fakeEqualSpacingViews.enumerated() {
                guard let prevFakeEqualSpacingView = fakeEqualSpacingViews[safe: i - 1] else { continue }
                constrain(fakeEqualSpacingView, prevFakeEqualSpacingView) { fakeView, prevFakeView in
                    fakeView.width == prevFakeView.width
                }
            }
        }

        return rowView
    }

    private func makeRowItemView(_ rowItem: ViewModel.RowItem) -> UIView {
        switch rowItem {
        case let .nestedSelfSizingRow(row):
            return makeRowView(row)

        case let .button(viewModel, design):
            return KeyboardButton(viewModel: viewModel, design: design)

        case let .caseChangeButton(viewModel, design):
            return CaseChangeKeyboardButton(caseChangeViewModel: viewModel, design: design)
        }
    }
}
