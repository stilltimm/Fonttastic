//
//  CanvasWithSettingsView.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 04.10.2021.
//

import UIKit
import Cartography

public class CanvasWithSettingsView: UIView {

    // MARK: - Public Instance Properties

    public let shouldToggleFontSelection = Event<Void>()
    public let shouldPresentTextColorPickerEvent = Event<Void>()
    public let shouldPresentBackgroundColorPickerEvent = Event<Void>()
    public let shouldPresentBackgroundImageSelectionEvent = Event<Void>()
    public let didChangeTextAlignmentEvent = Event<NSTextAlignment>()
    public let didCopyCanvasEvent = Event<CanvasViewDesign>()

    public var canvasFontModel: FontModel {
        get { canvasViewDesign.fontModel }
        set {
            canvasViewDesign.fontModel = newValue
            updateCanvasViewDesign()
        }
    }
    public var canvasFontSize: CGFloat {
        get { canvasViewDesign.fontSize }
        set {
            canvasViewDesign.fontSize = newValue
            updateCanvasViewDesign()
        }
    }
    public var canvasBackgroundColor: UIColor {
        get { canvasViewDesign.backgroundColor }
        set {
            canvasViewDesign.backgroundColor = newValue
            updateCanvasViewDesign()
        }
    }
    public var canvasBackgroundImage: UIImage? {
        get { canvasViewDesign.backgroundImage }
        set {
            canvasViewDesign.backgroundImage = newValue
            updateCanvasViewDesign()
        }
    }
    public var canvasTextColor: UIColor {
        get { canvasViewDesign.textColor }
        set {
            canvasViewDesign.textColor = newValue
            updateCanvasViewDesign()
        }
    }

    public var targetBackgroundImageSize: CGSize { canvasView.frame.size }

    // MARK: - Subviews

    private let canvasContainerScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.canCancelContentTouches = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.maximumZoomScale = 1.0
        scrollView.minimumZoomScale = 1.0

        scrollView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        scrollView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        return scrollView
    }()
    private let canvasContainerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        return button
    }()
    private let canvasView: CanvasView

    private let copiedStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Georgia-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = Colors.whiteAndBlack
        label.textAlignment = .center
        label.text = FonttasticToolsStrings.Keyboard.Canvas.Copied.title
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

    private let fontChangeViewModel = DefaultKeyboardButtonVM(
        normalIconName: "character.book.closed",
        highlightedIconName: "character.book.closed.fill"
    )
    private let textAlignmentChangeViewModel: TextAlignmentChangeButtonViewModel
    private let fontChangeButton: KeyboardButton
    private let backgroundColorChangeViewModel = DefaultKeyboardButtonVM(
        normalIconName: "square.fill",
        highlightedIconName: nil
    )
    private let backgroundImageSelectionViewModel = DefaultKeyboardButtonVM(
        normalIconName: "photo",
        highlightedIconName: nil
    )
    private let textColorChangeViewModel = DefaultKeyboardButtonVM(
        normalIconName: "textformat",
        highlightedIconName: nil
    )

    private let textAlignmentChangeButton: KeyboardButton
    private let backgroundColorChangeButton: KeyboardButton
    private let backgroundImageSelectionButton: KeyboardButton
    private let textColorChangeButton: KeyboardButton

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

    private var insertedText: [String]
    private var canvasViewDesign: CanvasViewDesign
    private var copiedStatusHideWorkItem: DispatchWorkItem?

    // MARK: - Initializers

    public init(insertedText: [String], canvasViewDesign: CanvasViewDesign) {
        self.insertedText = insertedText
        self.canvasViewDesign = canvasViewDesign
        self.canvasView = CanvasView(design: canvasViewDesign)

        functionalButtonDesign = keyboardButtonDesignBuilder
            .withForegroungColor(Colors.keyboardButtonMinor)
            .withHighlightedForegroundColor(Colors.keyboardButtonMain)
            .build()
        let backgroundChangeButtonDesign = keyboardButtonDesignBuilder
            .withIconSize(CGSize(width: 36, height: 36))
            .build()

        fontChangeButton = KeyboardButton(
            viewModel: fontChangeViewModel,
            design: functionalButtonDesign
        )
        backgroundColorChangeButton = KeyboardButton(
            viewModel: backgroundColorChangeViewModel,
            design: backgroundChangeButtonDesign
        )
        backgroundImageSelectionButton = KeyboardButton(
            viewModel: backgroundImageSelectionViewModel,
            design: functionalButtonDesign
        )
        textAlignmentChangeViewModel = TextAlignmentChangeButtonViewModel(
            textAlignment: canvasViewDesign.textAlignment
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
        updateCanvasViewText()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Instance Methods

    public func insertText(_ text: String) {
        insertedText.append(text)
        updateCanvasViewText()
    }

    public func deleteBackwards() {
        guard !insertedText.isEmpty else { return }
        insertedText.removeLast()
        updateCanvasViewText()
    }

    public func handleOrientationChange() {
//        canvasView.textView.sizeToFit()
    }

    // MARK: - Private Instance Methods

    // swiftlint:disable:next function_body_length
    private func setupSubviews() {
        let buttonsContainerView = UIView()
        buttonsContainerView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        buttonsContainerView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        let buttonViews = [
            fontChangeButton,
            textAlignmentChangeButton,
            backgroundColorChangeButton,
            backgroundImageSelectionButton,
            textColorChangeButton
        ]
        buttonViews.forEach { buttonsContainerView.addSubview($0) }
        for (i, buttonView) in buttonViews.enumerated() {
            if i == 0 {
                constrain(buttonsContainerView, buttonView) { container, button in
                    button.top == container.top
                    container.width == button.width
                }
            }

            if let prevButton = buttonViews[safe: i - 1] {
                constrain(prevButton, buttonView) { prevButton, button in
                    button.top == prevButton.bottom + Constants.buttonsSpacing
                }
            }

            if i == buttonViews.count - 1 {
                constrain(buttonsContainerView, buttonView) { container, button in
                    button.bottom == container.bottom
                }
            }

            constrain(buttonsContainerView, buttonView) { container, button in
                button.centerX == container.centerX
            }
        }

        addSubview(buttonsContainerView)
        addSubview(canvasContainerScrollView)
        canvasContainerScrollView.addSubview(canvasContainerButton)
        canvasContainerButton.addSubview(canvasView)

        constrain(
            self, buttonsContainerView, canvasContainerScrollView, canvasContainerButton, canvasView
        ) { view, buttonsContainer, scrollView, canvasContainer, canvas in
            buttonsContainer.centerY == view.centerY
            buttonsContainer.right == view.right - Constants.edgeInsets.right
            buttonsContainer.bottom <= view.bottom - Constants.edgeInsets.bottom
            buttonsContainer.top >= view.top + Constants.edgeInsets.top

            scrollView.top == view.top
            scrollView.left == view.left
            scrollView.right == buttonsContainer.left - Constants.buttonsToCanvasSpacing
            scrollView.bottom == view.bottom
            scrollView.height == CanvasView.minHeight + Constants.edgeInsets.bottom + Constants.edgeInsets.top

            canvasContainer.width == scrollView.width

            canvas.top == canvasContainer.top + Constants.edgeInsets.top
            canvas.left == canvasContainer.left + Constants.edgeInsets.left
            canvas.right == canvasContainer.right - Constants.buttonsToCanvasSpacing
            canvas.bottom == canvasContainer.bottom - Constants.edgeInsets.bottom
        }

        addSubview(copiedStatusContainerView)
        copiedStatusContainerView.addSubview(copiedStatusLabel)

        constrain(
            canvasContainerScrollView, copiedStatusContainerView, copiedStatusLabel
        ) { canvasContainer, statusContainer, statusLabel in
            statusContainer.center == canvasContainer.center

            statusLabel.edges == statusContainer.edges.inseted(by: Constants.statusInsets)
        }

        canvasView.isUserInteractionEnabled = false
        canvasContainerButton.frame.origin = .zero
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
        textAlignmentChangeViewModel.didChangeTextAligmentEvent.bind(to: didChangeTextAlignmentEvent)

        backgroundColorChangeViewModel.didTapEvent.subscribe(self) { [weak self] _ in
            self?.shouldPresentBackgroundColorPickerEvent.onNext(())
        }

        backgroundImageSelectionViewModel.didTapEvent.subscribe(self) { [weak self] _ in
            self?.shouldPresentBackgroundImageSelectionEvent.onNext(())
        }

        textColorChangeViewModel.didTapEvent.subscribe(self) { [weak self] _ in
            self?.shouldPresentTextColorPickerEvent.onNext(())
        }

        canvasContainerButton.addTarget(
            self,
            action: #selector(self.copyCanvasContainerScreenshot),
            for: .touchUpInside
        )

        canvasView.contentHeightChangedEvent.subscribe(self) { [weak self] contentHeight in
            self?.updateScrollViewContent(contentHeight: contentHeight)
        }
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

        DefaultFontsService.shared.lastUsedCanvasViewDesign = canvasViewDesign

        setCopiedStatusLabel(isHidden: true, animated: false)

        DispatchQueue.main.async {
            DefaultFontsService.shared.storeLastUsedSettings()
        }
    }

    private func updateScrollViewContent(contentHeight: CGFloat) {
        canvasContainerScrollView.contentSize = CGSize(
            width: canvasContainerScrollView.bounds.width,
            height: contentHeight
        )

        let bottomPointRect = CGRect(origin: CGPoint(x: 0, y: contentHeight), size: .zero)
        canvasContainerScrollView.scrollRectToVisible(bottomPointRect, animated: true)
    }

    @objc private func copyCanvasContainerScreenshot() {
        canvasView.canvasTextView.resignFirstResponder()
        canvasView.showWatermark()
        UIPasteboard.general.image = canvasContainerButton.takeScreenshot()
        canvasView.hideWatermark()

        setCopiedStatusLabel(isHidden: false, animated: true)
        let workItem = DispatchWorkItem { [weak self] in
            self?.setCopiedStatusLabel(isHidden: true, animated: true)
        }
        self.copiedStatusHideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)

        didCopyCanvasEvent.onNext(self.canvasViewDesign)
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
            UIView.animate(withConfig: .fastControl, animations: changes)
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

extension CanvasViewDesign {

    public static func `default`(fontModel: FontModel) -> CanvasViewDesign {
        return CanvasViewDesign(
            fontModel: fontModel,
            fontSize: 36,
            backgroundColor: .white,
            backgroundImage: nil,
            textColor: .black,
            textAlignment: .center
        )
    }
}
