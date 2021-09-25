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
        return scrollView
    }()
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.backgroundMain
        return view
    }()
    private let previewTextView: UITextView = {
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

        navigationItem.title = fontModel.name
        view.backgroundColor = Colors.backgroundMinor

        setupLayout()
        updateTextViewStyle()

        previewTextView.text = text
    }

    // MARK: - Private Methods

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(previewTextView)

        constrain(
            view, scrollView, containerView, previewTextView
        ) { (view, scrollView, container, textView) in
            scrollView.edges == view.edges

            textView.left == container.left + Constants.contentInsets.left
            textView.right == container.right - Constants.contentInsets.right
            textView.centerY == container.centerY
            textView.height == Constants.textViewMinimumHeight

            container.width == view.width - 2 * Constants.containerHorziontalMargins
            container.top == textView.top - Constants.contentInsets.top
            container.bottom == textView.bottom + Constants.contentInsets.top
        }
    }

    private func updateTextViewStyle() {
        previewTextView.textAlignment = textAlignment
        previewTextView.font = UIFontFactory.makeFont(from: fontModel, withSize: textSize)
    }
}

extension FontDetailsViewController: UITextViewDelegate {

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard textView === previewTextView else { return true }

        updateTextViewHeight(with: textView.contentSize.height)
        return true
    }

    private func updateTextViewHeight(with contentHeight: CGFloat) {
        guard
            let heightConstraint = textViewHeightConstraint,
            contentHeight != heightConstraint.constant
        else { return }

        heightConstraint.constant = contentHeight
        containerView.setNeedsLayout()
        view.layoutSubviews()
    }
}

private enum Constants {

    static let containerHorziontalMargins: CGFloat = 16
    static let contentInsets: UIEdgeInsets = .init(top: 24, left: 16, bottom: 24, right: 16)
    static let textViewMinimumHeight: CGFloat = 44.0

    static let initialText: String = "Quick brown fox jumps over the lazy dog"
    static let initialFontSize: CGFloat = 36.0
    static let initialFontAlignment: NSTextAlignment = .center
}
