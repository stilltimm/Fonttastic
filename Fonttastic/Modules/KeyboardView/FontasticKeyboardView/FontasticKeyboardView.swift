import UIKit
import Cartography
import FonttasticTools

class FontasticKeyboardView: UIView {

    // MARK: - Subviews

    let canvasWithSettingsView = CanvasWithSettingsView()
    lazy var latinKeyboardView = KeyboardView(viewModel: latinKeyboardViewModel)

    // MARK: - Public Instance Properties

    let latinKeyboardViewModel: LatinAlphabetQwertyKeyboardViewModel = .default()
    private var portraitOrientationConstraints: [NSLayoutConstraint] = []
    private var landscapeOrientationConstraints: [NSLayoutConstraint] = []

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupLayout()
        setupBusinessLogic()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Instance Methods

    func adaptToOrientationChange(isPortrait: Bool) {
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
        addSubview(latinKeyboardView)

        canvasWithSettingsView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        canvasWithSettingsView.setContentHuggingPriority(.defaultLow, for: .vertical)
        canvasWithSettingsView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        canvasWithSettingsView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        latinKeyboardView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        latinKeyboardView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        latinKeyboardView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        latinKeyboardView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        let realWidth = UIScreen.main.isPortrait ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
        constrain(self, canvasWithSettingsView, latinKeyboardView) { view, canvasWithSettings, latinKeyboard in
            // static constraints
            canvasWithSettings.top == view.top
            canvasWithSettings.right == view.right
            latinKeyboard.left == view.left
            latinKeyboard.bottom == view.bottom
            (latinKeyboard.width == realWidth).priority = .required

            // portrait orientation
            portraitOrientationConstraints.append(contentsOf: [
                canvasWithSettings.left == view.left,
                latinKeyboard.right == view.right,
                canvasWithSettings.bottom == latinKeyboard.top
            ])

            // landscape orientation
            landscapeOrientationConstraints.append(contentsOf: [
                canvasWithSettings.bottom == view.bottom,
                latinKeyboard.top == view.top,
                latinKeyboard.right == canvasWithSettings.left
            ])
        }

        adaptToOrientationChange(isPortrait: UIScreen.main.isPortrait)
    }

    private func setupBusinessLogic() {
        latinKeyboardViewModel.didSubmitSymbolEvent.subscribe(self) { [weak self] text in
            self?.canvasWithSettingsView.insertText(text)
        }

        latinKeyboardViewModel.shouldDeleteSymbolEvent.subscribe(self) { [weak self] in
            self?.canvasWithSettingsView.deleteBackwards()
        }
    }
}
