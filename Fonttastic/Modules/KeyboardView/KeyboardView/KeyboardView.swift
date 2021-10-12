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
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .center
        mainStackView.distribution = .fillEqually
        mainStackView.spacing = design.rowSpacing

        for row in viewModel.rows {
            let rowView = makeRowView(row)
            mainStackView.addArrangedSubview(rowView)
        }

        addSubview(mainStackView)
        constrain(self, mainStackView) { view, stackView in
            stackView.edges == view.edges.inseted(by: design.edgeInsets)
        }
    }

    private func makeRowView(_ row: ViewModel.Row) -> UIView {
        let rowStackView = UIStackView()
        rowStackView.axis = .horizontal
        rowStackView.alignment = .fill
        switch row.style {
        case let .fill(spacing):
            rowStackView.distribution = .fill
            rowStackView.spacing = spacing

        case let .fillEqually(spacing):
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = spacing
        }

        for item in row.items {
            let view = makeRowItemView(item)
            rowStackView.addArrangedSubview(view)
        }

        return rowStackView
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
