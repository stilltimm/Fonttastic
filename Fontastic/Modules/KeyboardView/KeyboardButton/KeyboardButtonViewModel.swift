//
//  KeyboardLabelButtonViewModel.swift
//  FontasticKeyboard
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import FontasticTools

// MARK: - Protocol

enum KeyboardButtonContent {

    case text(contentString: String, displayString: String)
    case systemIcon(normalIconName: String, highilightedIconName: String?)
}

protocol KeyboardButtonViewModelProtocol {

    var content: KeyboardButtonContent { get }
    var didTapEvent: Event<KeyboardButtonContent> { get }
    var shouldUpdateContentEvent: Event<Void> { get }
}

//enum KeyboardButtonViewModel: KeyboardButtonViewModelProtocol {
//
//    case `default`(DefaultKeyboardButtonViewModel)
//    case capitalizable(CapitalizableKeyboardButtonViewModel)
//
//    var content: KeyboardButtonContent {
//        switch self {
//        case let .default(viewModel):
//            return viewModel.content
//
//        case let .capitalizable(viewModel):
//            return viewModel.content
//        }
//    }
//
//    var didTapEvent: Event<KeyboardButtonContent> {
//        switch self {
//        case let .default(viewModel):
//            return viewModel.didTapEvent
//
//        case let .capitalizable(viewModel):
//            return viewModel.didTapEvent
//        }
//    }
//
//    var shouldUpdateContentEvent: Event<Void> {
//        switch self {
//        case let .default(viewModel):
//            return viewModel.shouldUpdateContentEvent
//
//        case let .capitalizable(viewModel):
//            return viewModel.shouldUpdateContentEvent
//        }
//    }
//}

// MARK: - Implementations

class DefaultKeyboardButtonViewModel: KeyboardButtonViewModelProtocol {

    // MARK: - Public Instance Properties

    let content: KeyboardButtonContent
    let didTapEvent = Event<KeyboardButtonContent>()
    let shouldUpdateContentEvent = Event<Void>()

    // MARK: - Initializers

    init(symbol: String) {
        self.content = .text(contentString: symbol, displayString: symbol)
    }

    init(symbol: String, displayString: String) {
        self.content = .text(contentString: symbol, displayString: displayString)
    }

    init(normalIconName: String, highlightedIconName: String) {
        self.content = .systemIcon(normalIconName: normalIconName, highilightedIconName: highlightedIconName)
    }
}

class CapitalizableKeyboardButtonViewModel: KeyboardButtonViewModelProtocol {

    // MARK: - Public Instance Properties

    let didTapEvent = Event<KeyboardButtonContent>()
    let shouldUpdateContentEvent = Event<Void>()
    var content: KeyboardButtonContent { isCapitalized ? capitalizedContent : uncapitalizedContent }

    // MARK: - Private Instance Properties

    private let uncapitalizedContent: KeyboardButtonContent
    private let capitalizedContent: KeyboardButtonContent
    private var isCapitalized: Bool = false

    // MARK: - Initializers

    init(
        uncapitalizedSymbol: String,
        capitalizedSymbol: String,
        capitalizationSource: FontasticTools.Event<Bool>
    ) {
        self.uncapitalizedContent = .text(contentString: uncapitalizedSymbol, displayString: uncapitalizedSymbol)
        self.capitalizedContent = .text(contentString: capitalizedSymbol, displayString: capitalizedSymbol)

        capitalizationSource.subscribe(self) { [weak self] isCapitalized in
            guard let self = self else { return }
            self.isCapitalized = isCapitalized
            self.shouldUpdateContentEvent.onNext(())
        }
    }
}

class LatinSpaceKeyboardButtonViewModel: DefaultKeyboardButtonViewModel {

    init() {
        super.init(symbol: " ", displayString: "space")
    }
}

class LatinReturnKeyboardButtonViewModel: DefaultKeyboardButtonViewModel {

    init() {
        super.init(symbol: "\n", displayString: "return")
    }
}

class BackspaceKeyboardButtonViewModel: DefaultKeyboardButtonViewModel {

    init(shouldDeleteSymbolEvent: Event<Void>) {
        super.init(normalIconName: "delete.left", highlightedIconName: "delete.left.fill")

        self.didTapEvent.subscribe(shouldDeleteSymbolEvent) { [weak shouldDeleteSymbolEvent] _ in
            shouldDeleteSymbolEvent?.onNext(())
        }
    }
}

class CaseChangeKeyboardButtonViewModel: KeyboardButtonViewModelProtocol {

    // MARK: - Nested Types

    enum State {

        case lowercase
        case uppercase
        case uppercaseLocked

        // MARK: - Instance Properties

        var isCapitalized: Bool {
            switch self {
            case .lowercase:
                return false

            case .uppercase, .uppercaseLocked:
                return true
            }
        }
    }

    // MARK: - Public Instance Properties

    var content: KeyboardButtonContent {
        switch state {
        case .lowercase:
            return lowercaseContent

        case .uppercase:
            return uppercaseContent

        case .uppercaseLocked:
            return uppercaseLockedContent
        }
    }
    let didTapEvent = Event<KeyboardButtonContent>()
    let shouldUpdateContentEvent = Event<Void>()

    var state: State = .lowercase {
        didSet {
            isCapitalizedEvent.onNext(state.isCapitalized)
        }
    }

    // MARK: - Private Instance Properties

    private let isCapitalizedEvent = HotEvent<Bool>(value: false)
    private var shouldTurnIntoLockedStateWorkItem: DispatchWorkItem?
    private var shouldTurnIntoLockedState: Bool = false

    private let lowercaseContent: KeyboardButtonContent = .systemIcon(
        normalIconName: "arrow.up",
        highilightedIconName: "arrow.up"
    )
    private let uppercaseContent: KeyboardButtonContent = .systemIcon(
        normalIconName: "arrow.up",
        highilightedIconName: "arrow.up"
    )
    private let uppercaseLockedContent: KeyboardButtonContent = .systemIcon(
        normalIconName: "arrow.up.to.line",
        highilightedIconName: "arrow.up.to.line"
    )

    // MARK: - Initializers

    init(capitalizationSource: Event<Bool>, textInsertedSource: Event<String>) {
        isCapitalizedEvent.subscribe(capitalizationSource) { [weak capitalizationSource] isCapitalized in
            capitalizationSource?.onNext(isCapitalized)
        }

        textInsertedSource.subscribe(self) { [weak self] _ in
            guard let self = self else { return }
            if self.state == .uppercase {
                self.state = .lowercase
            }
        }

        didTapEvent.subscribe(self) { [weak self] _ in
            guard let self = self else { return }

            if let workItem = self.shouldTurnIntoLockedStateWorkItem {
                workItem.cancel()
                self.shouldTurnIntoLockedStateWorkItem = nil
            }

            let targetState: State
            switch self.state {
            case .lowercase:
                targetState = .uppercase
                self.shouldTurnIntoLockedState = true
                let workItem = DispatchWorkItem { [weak self] in
                    self?.shouldTurnIntoLockedState = false
                    self?.shouldTurnIntoLockedStateWorkItem = nil
                }
                self.shouldTurnIntoLockedStateWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.uppercaseLockTimeout, execute: workItem)

            case .uppercase:
                targetState = self.shouldTurnIntoLockedState ? .uppercaseLocked : .lowercase
                self.shouldTurnIntoLockedState = false

            case .uppercaseLocked:
                targetState = .lowercase
                self.shouldTurnIntoLockedState = false
            }
            self.state = targetState
            print("CaseChangeKeyboardState: \(targetState)")
        }
    }
}

private enum Constants {

    static let uppercaseLockTimeout: TimeInterval = 0.5
}
