//
//  KeyboardViewTestController.swift
//  Fontastic
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import Cartography

class KeyboardViewTestViewController: UIViewController {

    // MARK: - Subviews

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.backgroundColor = .clear
        scrollView.canCancelContentTouches = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private let textContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.backgroundMain
        view.layer.masksToBounds = true
        view.layer.cornerRadius = Constants.containerCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        return textView
    }()
    private let latinAlphabetKeyboardView = KeyboardView(
        viewModel: LatinAlphabetQwertyKeyboardViewModel(
            design: .init(
                letterSpacing: 4,
                rowSpacing: 12,
                edgeInsets: .init(vertical: 4, horizontal: 2),
                symbolDesign: .init(
                    backgroundColor: UIColor(white: 0.5, alpha: 1.0),
                    foregroundColor: .white,
                    highlightedColor: UIColor(white: 0.98, alpha: 1.0),
                    shadowSize: 2.0 / UIScreen.main.scale,
                    cornerRadius: 5.0,
                    labelFont: UIFont.systemFont(ofSize: 26, weight: .regular)
                )
            )
        )
    )

    // MARK: - Private Properties

    private let fontModel: FontModel

    private var text: String = Constants.initialText
    private var textAlignment: NSTextAlignment = Constants.initialFontAlignment
    private var textSize: CGFloat = Constants.initialFontSize

    private var textViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Initializers

    init(fontModel: FontModel) {
        self.fontModel = fontModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = fontModel.displayName
        navigationItem.backButtonTitle = "Мои Шрифты"
        view.backgroundColor = Colors.backgroundMinor

        setupLayout()
        updateTextViewStyle()

        textView.text = text
    }

    // MARK: - Private Methods

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(textContainerView)
        textContainerView.addSubview(textView)

        constrain(
            view, scrollView, containerView, textContainerView, textView
        ) { (view, scrollView, container, textContainer, textView) in
            scrollView.edges == view.edges

            textView.edges == textContainer.edges.inseted(by: Constants.textInsets)
            let heightConstraint = (textView.height >= Constants.textViewMinimumHeight)
            heightConstraint.priority = .required

            textContainer.leading == container.leading + Constants.contentInsets.left
            textContainer.trailing == container.trailing - Constants.contentInsets.right
            textContainer.top == container.top + Constants.contentInsets.top

            container.width == view.width
        }

        containerView.addSubview(latinAlphabetKeyboardView)
        constrain(
            containerView, textContainerView, latinAlphabetKeyboardView
        ) { container, textContainer, keyboard in
            keyboard.leading == container.leading
            keyboard.trailing == container.trailing
            keyboard.height == 180
            keyboard.top == textContainer.bottom + 24

            container.bottom == keyboard.bottom + Constants.contentInsets.bottom
        }
    }

    private func updateTextViewStyle() {
        textView.textAlignment = textAlignment
        textView.font = UIFontFactory.makeFont(from: fontModel, withSize: textSize)
    }
}

private enum Constants {

    static let containerHorziontalMargins: CGFloat = 16
    static let contentInsets: UIEdgeInsets = .init(vertical: 24, horizontal: 16)
    static let textInsets: UIEdgeInsets = .init(vertical: 12, horizontal: 16)
    static let textViewMinimumHeight: CGFloat = 44.0

    static let containerCornerRadius: CGFloat = 32.0

    static let initialText: String = "Quick brown fox jumps over the lazy dog"
    static let initialFontSize: CGFloat = 36.0
    static let initialFontAlignment: NSTextAlignment = .center
}
