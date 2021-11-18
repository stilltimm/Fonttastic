//
//  KeyboardLabelButtonViewModel.swift
//  FontasticKeyboard
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit

// MARK: - Protocol

public enum KeyboardButtonContent {

    case text(contentString: String?, displayString: String)
    case systemIcon(normalIconName: String, highilightedIconName: String?)
}

public protocol KeyboardButtonViewModelProtocol {

    var content: KeyboardButtonContent { get }
    var didTapEvent: Event<KeyboardButtonContent> { get }
    var shouldUpdateContentEvent: Event<Void> { get }
}

// MARK: - Implementations

public class DefaultKeyboardButtonVM: KeyboardButtonViewModelProtocol {

    // MARK: - Public Instance Properties

    public let content: KeyboardButtonContent
    public let didTapEvent = Event<KeyboardButtonContent>()
    public let shouldUpdateContentEvent = Event<Void>()

    // MARK: - Initializers

    public init(symbol: String) {
        self.content = .text(contentString: symbol, displayString: symbol)
    }

    public init(symbol: String, displayString: String) {
        self.content = .text(contentString: symbol, displayString: displayString)
    }

    public init(normalIconName: String, highlightedIconName: String?) {
        self.content = .systemIcon(normalIconName: normalIconName, highilightedIconName: highlightedIconName)
    }
}

public class CapitalizableKeyboardButtonVM: KeyboardButtonViewModelProtocol {

    // MARK: - Public Instance Properties

    public let didTapEvent = Event<KeyboardButtonContent>()
    public let shouldUpdateContentEvent = Event<Void>()
    public var content: KeyboardButtonContent { isCapitalized ? capitalizedContent : uncapitalizedContent }

    // MARK: - Private Instance Properties

    private let uncapitalizedContent: KeyboardButtonContent
    private let capitalizedContent: KeyboardButtonContent
    private var isCapitalized: Bool = false

    // MARK: - Initializers

    public init(
        uncapitalizedSymbol: String,
        capitalizedSymbol: String,
        capitalizationSource: FonttasticTools.Event<Bool>
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

public class LatinSpaceKeyboardButtonVM: DefaultKeyboardButtonVM {

    public init() {
        super.init(symbol: " ", displayString: "space")
    }
}

public class LatinReturnKeyboardButtonVM: DefaultKeyboardButtonVM {

    public init() {
        super.init(symbol: "\n", displayString: "return")
    }
}

public class BackspaceKeyboardButtonVM: DefaultKeyboardButtonVM {

    public init(shouldDeleteSymbolEvent: Event<Void>) {
        super.init(normalIconName: "delete.left", highlightedIconName: "delete.left.fill")

        self.didTapEvent.subscribe(shouldDeleteSymbolEvent) { [weak shouldDeleteSymbolEvent] _ in
            shouldDeleteSymbolEvent?.onNext(())
        }
    }
}

public class CaseChangeKeyboardButtonVM: KeyboardButtonViewModelProtocol {

    // MARK: - Nested Types

    public enum State {

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

    public var content: KeyboardButtonContent {
        switch state {
        case .lowercase:
            return lowercaseContent

        case .uppercase:
            return uppercaseContent

        case .uppercaseLocked:
            return uppercaseLockedContent
        }
    }
    public let didTapEvent = Event<KeyboardButtonContent>()
    public let shouldUpdateContentEvent = Event<Void>()
    public let isCapitalizedEvent = HotEvent<Bool>(value: false)

    public var state: State = .lowercase {
        didSet {
            isCapitalizedEvent.onNext(state.isCapitalized)
            shouldUpdateContentEvent.onNext(())
        }
    }

    // MARK: - Private Instance Properties

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

    public init(capitalizationSource: Event<Bool>, textInsertedSource: Event<String>) {
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
        }
    }
}

public class PunctuationSetToggleKeyboardButtonVM: KeyboardButtonViewModelProtocol {

    // MARK: - Public Instance Properties

    public let didTapEvent = Event<KeyboardButtonContent>()
    public let shouldUpdateContentEvent = Event<Void>()
    public let content: KeyboardButtonContent

    // MARK: - Initializers

    public init(punctuationSet: KeyboardType.PunctuationSet, punctuationSetToggleEvent: Event<Void>) {
        switch punctuationSet {
        case .default:
            self.content = .text(contentString: nil, displayString: "#+=")

        case .alternative:
            self.content = .systemIcon(normalIconName: "textformat.123", highilightedIconName: nil)
        }

        didTapEvent.subscribe(punctuationSetToggleEvent) { [weak punctuationSetToggleEvent] _ in
            punctuationSetToggleEvent?.onNext(())
        }
    }
}

public class LanguageToggleKeyboardButtonVM: KeyboardButtonViewModelProtocol {

    // MARK: - Public Instance Properties

    public let didTapEvent = Event<KeyboardButtonContent>()
    public let shouldUpdateContentEvent = Event<Void>()
    public var content: KeyboardButtonContent {
        switch lastUsedLanguage {
        case .latin:
            return latinLanguageContent

        case .cyrillic:
            return cyrillicLanguageContent
        }
    }

    // MARK: - Private Instance Properties

    private let latinLanguageContent = KeyboardButtonContent.text(contentString: nil, displayString: "EN")
    private let cyrillicLanguageContent = KeyboardButtonContent.text(contentString: nil, displayString: "RU")
    private var lastUsedLanguage: KeyboardType.Language = DefaultFontsService.shared.lastUsedLanguage

    // MARK: - Initializers

    public init(
        lastUsedLanguageSource: Event<KeyboardType.Language>,
        languageToggleEvent: Event<Void>
    ) {
        didTapEvent.subscribe(languageToggleEvent) { [weak languageToggleEvent] _ in
            languageToggleEvent?.onNext(())
        }

        lastUsedLanguageSource.subscribe(self) { [weak self] language in
            guard let self = self else { return }
            self.lastUsedLanguage = language
            self.shouldUpdateContentEvent.onNext(())
        }
    }
}

// swiftlint:disable:next type_name
public class LanguagePunctuationToggleKeyboardButtonVM: KeyboardButtonViewModelProtocol {

    // MARK: - Public Instance Properties

    public let didTapEvent = Event<KeyboardButtonContent>()
    public let shouldUpdateContentEvent = Event<Void>()
    public let content: KeyboardButtonContent

    // MARK: - Initializers

    public init(keyboardType: KeyboardType, languagePunctuationToggleEvent: Event<Void>) {
        switch keyboardType {
        case .language:
            self.content = .systemIcon(normalIconName: "textformat.123", highilightedIconName: nil)

        case .punctuation:
            self.content = .systemIcon(normalIconName: "abc", highilightedIconName: nil)
        }

        didTapEvent.subscribe(languagePunctuationToggleEvent) { [weak languagePunctuationToggleEvent] _ in
            languagePunctuationToggleEvent?.onNext(())
        }
    }
}

public class TextAlignmentChangeButtonViewModel: KeyboardButtonViewModelProtocol {

    // MARK: - Public Instance Properties

    public var content: KeyboardButtonContent {
        switch self.textAlignment {
        case .center:
            return centerAlignmentContent

        case .left:
            return leftAlignmentContent

        case .right:
            return rightAlignmentContent

        default:
            return centerAlignmentContent
        }
    }
    public let didTapEvent = Event<KeyboardButtonContent>()
    public let shouldUpdateContentEvent = Event<Void>()
    public lazy var didChangeTextAligmentEvent = HotEvent<NSTextAlignment>(value: textAlignment)

    public var textAlignment: NSTextAlignment {
        didSet {
            shouldUpdateContentEvent.onNext(())
            didChangeTextAligmentEvent.onNext(textAlignment)
        }
    }

    // MARK: - Private Instance Properties

    private var shouldTurnIntoLockedStateWorkItem: DispatchWorkItem?
    private var shouldTurnIntoLockedState: Bool = false

    private let leftAlignmentContent: KeyboardButtonContent = .systemIcon(
        normalIconName: "text.alignleft",
        highilightedIconName: nil
    )
    private let centerAlignmentContent: KeyboardButtonContent = .systemIcon(
        normalIconName: "text.aligncenter",
        highilightedIconName: nil
    )
    private let rightAlignmentContent: KeyboardButtonContent = .systemIcon(
        normalIconName: "text.alignright",
        highilightedIconName: nil
    )

    // MARK: - Initializers

    public init(textAlignment: NSTextAlignment) {
        self.textAlignment = textAlignment
        didTapEvent.subscribe(self) { [weak self] _ in
            guard let self = self else { return }

            let targetTextAlignment: NSTextAlignment
            switch self.textAlignment {
            case .center:
                targetTextAlignment = .left

            case .left:
                targetTextAlignment = .right

            case .right:
                targetTextAlignment = .center

            default:
                targetTextAlignment = Constants.defaultTextAlignment
            }
            self.textAlignment = targetTextAlignment
        }
    }
}

private enum Constants {

    static let defaultTextAlignment: NSTextAlignment = .center
    static let uppercaseLockTimeout: TimeInterval = 0.3
}
