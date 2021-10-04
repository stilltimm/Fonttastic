//
//  CanvasWithSettingsView.swift
//  Fontastic
//
//  Created by Timofey Surkov on 04.10.2021.
//

import UIKit
import Cartography
import FontasticTools

class CanvasWithSettingsView: UIView {

    // MARK: - Public Instance Properties

    let shouldToggleFontSelection = Event<Void>()
    let shouldPresentTextColorPickerEvent = Event<Void>()
    let shouldPresentBackgroundColorPickerEvent = Event<Void>()

    // MARK: - Subviews

    private let canvasView: CanvasView

    private let fontChangeViewModel = DefaultKeyboardButtonViewModel(
        normalIconName: "character.book.closed",
        highlightedIconName: "character.book.closed.fill"
    )
    private let fontChangeButton: KeyboardButton

    private let textAlignmentChangeViewModel = TextAlignmentChangeButtonViewModel()
    private let textAlignmentChangeButton: KeyboardButton

    private let backgroundColorChangeViewModel = DefaultKeyboardButtonViewModel(
        normalIconName: "square.fill",
        highlightedIconName: nil
    )
    private let backgroundColorChangeButton: KeyboardButton

    private let textColorChangeViewModel = DefaultKeyboardButtonViewModel(
        normalIconName: "character.cursor.ibeam",
        highlightedIconName: nil
    )
    private let textColorChangeButton: KeyboardButton

    private var insertedText: [String] = []
    private var canvasViewDesign: CanvasView.Design = .default

    private let keyboardButtonDesignBuilder = KeyboardButtonDesignBuilder(
        .default(
            fixedWidth: 44.0,
            touchOutset: .init(
                top: Constants.buttonsSpacing / 2,
                left: Constants.edgeInsets.left,
                bottom: Constants.buttonsSpacing / 2,
                right: Constants.buttonsToCanvasSpacing
            )
        )
    )
    private let functionalButtonDesign: KeyboardButtonDesign

    // MARK: - Initializers

    init() {
        functionalButtonDesign = keyboardButtonDesignBuilder
            .withForegroungColor(Colors.keyboardButtonMinor)
            .withHighlightedForegroundColor(Colors.keyboardButtonMain)
            .build()
        canvasView = CanvasView(design: canvasViewDesign)

        fontChangeButton = KeyboardButton(
            viewModel: fontChangeViewModel,
            design: functionalButtonDesign
        )
        backgroundColorChangeButton = KeyboardButton(
            viewModel: backgroundColorChangeViewModel,
            design: functionalButtonDesign
        )

        textAlignmentChangeButton = KeyboardButton(
            viewModel: textAlignmentChangeViewModel,
            design: functionalButtonDesign
        )
        textColorChangeButton = KeyboardButton(
            viewModel: textColorChangeViewModel,
            design: functionalButtonDesign
        )

        super.init(frame: .zero)

        setupSubviews()
        setupBusinessLogic()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Instance Methods

    func insertText(_ text: String) {
        insertedText.append(text)
        updateCanvasViewText()
    }

    func deleteBackwards() {
        guard !insertedText.isEmpty else { return }
        insertedText.removeLast()
        updateCanvasViewText()
    }

    // MARK: - Private Instance Methods

    private func setupSubviews() {
        let buttonsStackView = UIStackView()
        buttonsStackView.axis = .vertical
        buttonsStackView.distribution = .fill
        buttonsStackView.alignment = .fill
        buttonsStackView.spacing = Constants.buttonsSpacing

        buttonsStackView.addArrangedSubview(fontChangeButton)
        buttonsStackView.addArrangedSubview(textAlignmentChangeButton)
        buttonsStackView.addArrangedSubview(backgroundColorChangeButton)
        buttonsStackView.addArrangedSubview(textColorChangeButton)
        addSubview(buttonsStackView)
        addSubview(canvasView)

        constrain(self, buttonsStackView, canvasView) { view, buttonsStack, canvas in
            canvas.top == view.top + Constants.edgeInsets.top
            canvas.right == view.right - Constants.edgeInsets.right
            canvas.bottom == view.bottom - Constants.edgeInsets.bottom

            buttonsStack.top == canvas.top
            buttonsStack.bottom == canvas.bottom
            buttonsStack.left == view.left + Constants.edgeInsets.left
            buttonsStack.right == canvas.left - Constants.buttonsToCanvasSpacing
        }
    }

    private func setupBusinessLogic() {
        textAlignmentChangeViewModel.didChangeTextAligmentEvent.subscribe(self) { [weak self] textAlignment in
            guard let self = self else { return }
            self.canvasViewDesign.textAlignment = textAlignment
            self.updateCanvasViewDesign()
        }

        fontChangeViewModel.didTapEvent.subscribe(self) { [weak self] _ in
            self?.shouldToggleFontSelection.onNext(())
        }
    }

    private func updateCanvasViewText() {
        let text = insertedText.joined()
        canvasView.setText(text)
    }

    private func updateCanvasViewDesign() {
        canvasView.applyDesign(canvasViewDesign)
    }
}

private enum Constants {

    static let edgeInsets: UIEdgeInsets = .init(
        top: 11,
        left: 11,
        bottom: 11,
        right: 11
    )

    static let buttonsToCanvasSpacing: CGFloat = 11
    static let buttonsSpacing: CGFloat = 6
}
