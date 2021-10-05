import UIKit
import Cartography

class FontasticKeyboardView: UIView {

    // MARK: - Subviews

    let canvasWithSettingsView = CanvasWithSettingsView()
    lazy var latinKeyboardView = KeyboardView(viewModel: latinKeyboardViewModel)

    // MARK: - Public Instance Properties

    let latinKeyboardViewModel: LatinAlphabetQwertyKeyboardViewModel = .default()

    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)

        setupLayout()
        setupBusinessLogic()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Instance Methods

    private func setupLayout() {
        addSubview(canvasWithSettingsView)
        addSubview(latinKeyboardView)

        constrain(self, canvasWithSettingsView, latinKeyboardView) { view, canvasWithSettings, latinKeyboard in
            canvasWithSettings.top == view.top
            canvasWithSettings.left == view.left
            canvasWithSettings.right == view.right
            canvasWithSettings.bottom == latinKeyboard.top

            latinKeyboard.left == view.left
            latinKeyboard.right == view.right
            latinKeyboard.bottom == view.bottom
        }
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
