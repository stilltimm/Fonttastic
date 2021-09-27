//
//  KeyboardView.swift
//  FontasticKeyboard
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import Cartography
import FontasticTools

class KeyboardView: UIView {

    // MARK: - Nested Types

    typealias ViewModel = KeyboardViewModel

    private let viewModel: ViewModel
    var design: ViewModel.Design { viewModel.design }

    let didSubmitSymbolEvent = Event<String>()

    // MARK: - Initializers

    init(viewModel: ViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("Unimplemented")
    }

    // MARK: - Instance Methods

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        setupLayout()

        didSubmitSymbolEvent.subscribe(self) { symbol in
            print(symbol)
        }
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
        case .equallySpaced:
            rowStackView.distribution = .equalSpacing

        case let .fullWidth(spacing):
            rowStackView.distribution = .fill
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

        case let .symbolButton(symbolViewModel):
            symbolViewModel.didTapEvent.subscribe(self) { [weak self] symbol in
                self?.didSubmitSymbolEvent.onNext(symbol)
            }
            return SymbolButton(viewModel: symbolViewModel, design: design.symbolDesign)
        }
    }
}
