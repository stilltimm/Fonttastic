//
//  FontDetailsViewController.swift
//  Fontastic
//
//  Created by Timofey Surkov on 25.09.2021.
//

import UIKit
import Cartography

class FontDetailsViewController: UIViewController {

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

            textContainer.edges == container.edges.inseted(by: Constants.contentInsets)

            container.width == view.width
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
