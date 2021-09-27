//
//  KeyboardLabelButtonViewModel.swift
//  FontasticKeyboard
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import FontasticTools

enum KeyboardLabelButtonStyle {
    case fixed(width: CGFloat)
    case flexible(flexBasis: CGFloat)
}

protocol KeyboardLabelButtonViewModelProtocol {

    var symbol: String { get }
    var style: KeyboardLabelButtonStyle { get }
    var didTapEvent: FontasticTools.Event<String> { get }
}

enum KeyboardLabelButtonViewModel: KeyboardLabelButtonViewModelProtocol {

    case symbol(SymbolViewModel)
    case capitalizableSymbol(CapitalizableSymbolViewModel)

    var symbol: String {
        switch self {
        case let .symbol(viewModel):
            return viewModel.symbol

        case let .capitalizableSymbol(viewModel):
            return viewModel.symbol
        }
    }

    var style: KeyboardLabelButtonStyle {
        switch self {
        case let .symbol(viewModel):
            return viewModel.style

        case let .capitalizableSymbol(viewModel):
            return viewModel.style
        }
    }

    var didTapEvent: FontasticTools.Event<String> {
        switch self {
        case let .symbol(viewModel):
            return viewModel.didTapEvent

        case let .capitalizableSymbol(viewModel):
            return viewModel.didTapEvent
        }
    }
}

class SymbolViewModel: KeyboardLabelButtonViewModelProtocol {

    let symbol: String
    let style: KeyboardLabelButtonStyle
    let didTapEvent = FontasticTools.Event<String>()

    init(symbol: String, style: KeyboardLabelButtonStyle) {
        self.symbol = symbol
        self.style = style
    }
}

class CapitalizableSymbolViewModel: KeyboardLabelButtonViewModelProtocol {

    let uncapitalizedSymbol: String
    let capitalizedSymbol: String
    var isCapitalized: Bool = false
    let style: KeyboardLabelButtonStyle
    let didTapEvent = FontasticTools.Event<String>()
    let didChangeSymbolEvent = FontasticTools.Event<String>()

    var symbol: String { isCapitalized ? capitalizedSymbol : uncapitalizedSymbol }

    init(
        uncapitalizedSymbol: String,
        capitalizedSymbol: String,
        style: KeyboardLabelButtonStyle,
        capitalizationSource: FontasticTools.Event<Bool>
    ) {
        self.uncapitalizedSymbol = uncapitalizedSymbol
        self.capitalizedSymbol = capitalizedSymbol
        self.style = style

        capitalizationSource.subscribe(self) { [weak self] isCapitalized in
            guard let self = self else { return }
            self.isCapitalized = isCapitalized
            self.didChangeSymbolEvent.onNext(self.symbol)
        }
    }
}
