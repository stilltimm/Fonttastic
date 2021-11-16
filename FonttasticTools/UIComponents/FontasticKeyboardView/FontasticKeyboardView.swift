import UIKit
import Cartography

public class FontasticKeyboardView: UIView {

    // MARK: - Subviews

    public let canvasWithSettingsView: CanvasWithSettingsView
    public let keyboardsContainerView = UIView()
    public let keyboardViews: [KeyboardView]

    // MARK: - Public Instance Properties

    public let keyboardViewModels: [KeyboardViewModel]

    // MARK: - Private Instance Properties

    private var portraitOrientationConstraints: [NSLayoutConstraint] = []
    private var landscapeOrientationConstraints: [NSLayoutConstraint] = []

    private var lastUsedLanguage: KeyboardType.Language = .latin {
        didSet {
            lastUsedLanguageEvent.onNext(lastUsedLanguage)
        }
    }
    private let lastUsedLanguageEvent: HotEvent<KeyboardType.Language>
    private var currentKeyboardType: KeyboardType = .language(.latin) {
        didSet {
            updateUI(for: currentKeyboardType)
        }
    }

    // MARK: - Initializers

    public init(initiallySelectedFontModel: FontModel) {
        self.canvasWithSettingsView = CanvasWithSettingsView(fontModel: initiallySelectedFontModel)
        let lastUsedLanguageEvent = HotEvent<KeyboardType.Language>(value: .latin)
        self.lastUsedLanguageEvent = lastUsedLanguageEvent

        keyboardViewModels = KeyboardType.allCases.map {
            KeyboardViewModel(config: .default(for: $0), lastUsedLanguageSource: lastUsedLanguageEvent)
        }
        keyboardViews = keyboardViewModels.map { KeyboardView(viewModel: $0)  }

        super.init(frame: .zero)

        setupLayout()
        setupBusinessLogic()

        updateUI(for: currentKeyboardType)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Instance Methods

    public func adaptToOrientationChange(isPortrait: Bool) {
        if isPortrait {
            NSLayoutConstraint.deactivate(landscapeOrientationConstraints)
            NSLayoutConstraint.activate(portraitOrientationConstraints)
        } else {
            NSLayoutConstraint.deactivate(portraitOrientationConstraints)
            NSLayoutConstraint.activate(landscapeOrientationConstraints)
        }

        canvasWithSettingsView.handleOrientationChange()
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        addSubview(canvasWithSettingsView)
        addSubview(keyboardsContainerView)

        canvasWithSettingsView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        canvasWithSettingsView.setContentHuggingPriority(.defaultLow, for: .vertical)
        canvasWithSettingsView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        canvasWithSettingsView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        keyboardsContainerView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        keyboardsContainerView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        keyboardsContainerView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        keyboardsContainerView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        let screenPortraitWidth = UIScreen.main.portraitWidth
        constrain(
            self, canvasWithSettingsView, keyboardsContainerView
        ) { view, canvasWithSettings, keyboardsContainer in
            // static constraints
            canvasWithSettings.top == view.top
            canvasWithSettings.right == view.right
            keyboardsContainer.left == view.left
            keyboardsContainer.bottom == view.bottom

            // portrait orientation
            portraitOrientationConstraints.append(contentsOf: [
                canvasWithSettings.left == view.left,
                keyboardsContainer.right == view.right,
                canvasWithSettings.bottom == keyboardsContainer.top
            ])

            // landscape orientation
            landscapeOrientationConstraints.append(contentsOf: [
                canvasWithSettings.bottom == view.bottom,
                keyboardsContainer.top == view.top,
                keyboardsContainer.right == canvasWithSettings.left,
                keyboardsContainer.width == screenPortraitWidth
            ])
        }

        keyboardViews.forEach { keyboardView in
            keyboardsContainerView.addSubview(keyboardView)
            constrain(keyboardsContainerView, keyboardView) { container, keyboard in
                keyboard.edges == container.edges
            }
        }

        adaptToOrientationChange(isPortrait: UIScreen.main.isPortrait)
    }

    private func setupBusinessLogic() {
        keyboardViewModels.forEach { keyboardViewModel in
            keyboardViewModel.didSubmitSymbolEvent.subscribe(self) { [weak self] text in
                self?.canvasWithSettingsView.insertText(text)
            }
            keyboardViewModel.shouldDeleteSymbolEvent.subscribe(self) { [weak self] in
                self?.canvasWithSettingsView.deleteBackwards()
            }
            keyboardViewModel.punctuationLanguageToggleEvent.subscribe(self) { [weak self] in
                self?.toggleLanguagePunctuation()
            }
            keyboardViewModel.languageToggleEvent.subscribe(self) { [weak self] in
                self?.toggleLanguage()
            }
            keyboardViewModel.punctuationSetToggleEvent.subscribe(self) { [weak self] in
                self?.togglePunctuationSet()
            }
        }
    }

    private func toggleLanguagePunctuation() {
        switch currentKeyboardType {
        case .language:
            applyKeyboardType(.punctuation(.default))

        case .punctuation:
            applyKeyboardType(.language(lastUsedLanguage))
        }
    }

    private func toggleLanguage() {
        applyKeyboardType(.language(lastUsedLanguage.next))
    }

    private func togglePunctuationSet() {
        switch currentKeyboardType {
        case .language:
            break

        case let .punctuation(punctuationSet):
            applyKeyboardType(.punctuation(punctuationSet.next))
        }
    }

    // MARK: - KeyboardType Changes Handling

    private func applyKeyboardType(_ keyboardType: KeyboardType) {
        guard keyboardType != self.currentKeyboardType else { return }

        self.currentKeyboardType = keyboardType
        switch keyboardType {
        case let .language(language):
            if language != lastUsedLanguage {
                lastUsedLanguage = language
            }

        case .punctuation:
            break
        }
        updateUI(for: keyboardType)
    }

    private func updateUI(for keyboardType: KeyboardType) {
        keyboardViews.forEach { keyboardView in
            keyboardView.isHidden = (keyboardView.keyboardType != keyboardType)
        }
    }
}
