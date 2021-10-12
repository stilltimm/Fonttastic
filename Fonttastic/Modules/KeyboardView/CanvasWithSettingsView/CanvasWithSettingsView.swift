//
//  CanvasWithSettingsView.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 04.10.2021.
//

import UIKit
import Cartography
import FonttasticTools

class CanvasWithSettingsView: UIView {

    // MARK: - Public Instance Properties

    let shouldToggleFontSelection = Event<Void>()
    let shouldPresentTextColorPickerEvent = Event<Void>()
    let shouldPresentBackgroundColorPickerEvent = Event<Void>()

    var canvasLabelFont: UIFont {
        get { canvasViewDesign.font }
        set {
            canvasViewDesign.font = newValue
            updateCanvasViewDesign()
        }
    }
    var canvasBackgroundColor: UIColor {
        get { canvasViewDesign.backgroundColor }
        set {
            canvasViewDesign.backgroundColor = newValue
            updateCanvasViewDesign()
        }
    }
    var canvasTextColor: UIColor {
        get { canvasViewDesign.textColor }
        set {
            canvasViewDesign.textColor = newValue
            updateCanvasViewDesign()
        }
    }

    // MARK: - Subviews

    private let canvasContainerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        return button
    }()
    private let canvasView = CanvasView()

    private let copiedStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Georgia-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = Colors.whiteAndBlack
        label.textAlignment = .center
        label.text = "✅ Copied"
        label.isUserInteractionEnabled = false
        return label
    }()
    private let copiedStatusContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.blackAndWhite
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 16.0
        view.layer.cornerCurve = .continuous
        return view
    }()

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

    private var copiedStatusHideWorkItem: DispatchWorkItem?

    // MARK: - Initializers

    init() {
        functionalButtonDesign = keyboardButtonDesignBuilder
            .withForegroungColor(Colors.keyboardButtonMinor)
            .withHighlightedForegroundColor(Colors.keyboardButtonMain)
            .build()

        fontChangeButton = KeyboardButton(
            viewModel: fontChangeViewModel,
            design: functionalButtonDesign
        )

        let backgroundChangeButtonDesign = keyboardButtonDesignBuilder
            .withIconSize(CGSize(width: 36, height: 36))
            .build()
        backgroundColorChangeButton = KeyboardButton(
            viewModel: backgroundColorChangeViewModel,
            design: backgroundChangeButtonDesign
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
        addSubview(canvasContainerButton)
        canvasContainerButton.addSubview(canvasView)

        constrain(
            self, buttonsStackView, canvasContainerButton, canvasView
        ) { view, buttonsStack, canvasContainer, canvas in
            canvasContainer.top == view.top
            canvasContainer.left == view.left
            canvasContainer.bottom == view.bottom

            buttonsStack.centerY == canvasContainer.centerY
            buttonsStack.right == view.right - Constants.edgeInsets.right
            buttonsStack.left == canvasContainer.right + Constants.buttonsToCanvasSpacing
            buttonsStack.bottom <= view.bottom - Constants.edgeInsets.bottom
            buttonsStack.top >= view.top + Constants.edgeInsets.top

            canvas.top == canvasContainer.top + Constants.edgeInsets.top
            canvas.left == canvasContainer.left + Constants.edgeInsets.left
            canvas.right == canvasContainer.right - Constants.buttonsToCanvasSpacing
            canvas.bottom == canvasContainer.bottom - Constants.edgeInsets.bottom
        }

        addSubview(copiedStatusContainerView)
        copiedStatusContainerView.addSubview(copiedStatusLabel)

        constrain(
            canvasContainerButton, copiedStatusContainerView, copiedStatusLabel
        ) { canvasContainer, statusContainer, statusLabel in
            statusContainer.center == canvasContainer.center

            statusLabel.edges == statusContainer.edges.inseted(by: Constants.statusInsets)
        }

        canvasView.isUserInteractionEnabled = false
        updateCanvasViewDesign()
    }

    private func setupBusinessLogic() {
        fontChangeViewModel.didTapEvent.subscribe(self) { [weak self] _ in
            self?.shouldToggleFontSelection.onNext(())
        }

        textAlignmentChangeViewModel.didChangeTextAligmentEvent.subscribe(self) { [weak self] textAlignment in
            guard let self = self else { return }
            self.canvasViewDesign.textAlignment = textAlignment
            self.updateCanvasViewDesign()
        }

        backgroundColorChangeViewModel.didTapEvent.subscribe(self) { [weak self] _ in
            self?.shouldPresentBackgroundColorPickerEvent.onNext(())
        }

        textColorChangeViewModel.didTapEvent.subscribe(self) { [weak self] _ in
            self?.shouldPresentTextColorPickerEvent.onNext(())
        }

        canvasContainerButton.addTarget(self, action: #selector(self.copyCanvasContainerScreenshot), for: .touchUpInside)
    }

    private func updateCanvasViewText() {
        let text = insertedText.joined()
        canvasView.setText(text)
        setCopiedStatusLabel(isHidden: true, animated: false)
    }

    private func updateCanvasViewDesign() {
        canvasView.applyDesign(canvasViewDesign)
        backgroundColorChangeButton.iconImageView.tintColor = canvasViewDesign.backgroundColor
        textColorChangeButton.iconImageView.tintColor = canvasViewDesign.textColor

        setCopiedStatusLabel(isHidden: true, animated: false)
    }

    @objc private func copyCanvasContainerScreenshot() {
        let generalPasteboard = UIPasteboard.general
        canvasView.textView.resignFirstResponder()
        generalPasteboard.image = canvasContainerButton.takeScreenshot(backgroundColor: .white)

        setCopiedStatusLabel(isHidden: false, animated: true)
        let workItem = DispatchWorkItem { [weak self] in
            self?.setCopiedStatusLabel(isHidden: true, animated: true)
        }
        self.copiedStatusHideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
    }

    private func setCopiedStatusLabel(isHidden: Bool, animated: Bool) {
        let changes = { [weak self] in
            guard let self = self else { return }
            self.canvasContainerButton.alpha = isHidden ? 1.0 : 0.3
            self.copiedStatusContainerView.isHidden = isHidden
        }

        if let workItem = copiedStatusHideWorkItem {
            workItem.cancel()
            copiedStatusHideWorkItem = nil
        }

        if animated {
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                options: .curveEaseInOut,
                animations: changes,
                completion: nil
            )
        } else {
            changes()
        }
    }
}

private enum Constants {

    static let edgeInsets: UIEdgeInsets = .init(
        top: 11,
        left: 11,
        bottom: 11,
        right: 11
    )

    static let statusInsets: UIEdgeInsets = .init(vertical: 16, horizontal: 20)

    static let buttonsToCanvasSpacing: CGFloat = 11
    static let buttonsSpacing: CGFloat = 6
}
