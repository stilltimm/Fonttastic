//
//  FontDetailsViewController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 25.09.2021.
//

import UIKit
import Cartography
import FonttasticTools

class FontDetailsViewController: UIViewController {

    // MARK: - Subviews

    private let backgroundView: UIView = {
        let imageView = UIImageView(image: UIImage(named: "bg"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
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
        let view = LinearGradientView(linearGradient: .glass)
        view.layer.cornerRadius = Constants.containerCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        return textView
    }()

    // MARK: - Private Properties

    private let fontModel: FontModel

    private var text: String = ""
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

        view.backgroundColor = Colors.backgroundMain

        setupLayout()
        updateTextViewStyle()

        textView.text = Constants.placeholderText
        textView.textColor = Constants.placeholderTextColor
        textView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        textView.becomeFirstResponder()
    }

    // MARK: - Private Methods

    private func setupLayout() {
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(textContainerView)
        textContainerView.addSubview(textView)

        constrain(
            view, backgroundView, scrollView, containerView, textContainerView, textView
        ) { (view, background, scrollView, container, textContainer, textView) in
            background.edges == view.edges
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

    @objc private func handleExportTap() {
        textView.resignFirstResponder()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let cornerRadius = self.textContainerView.layer.cornerRadius
            self.textContainerView.layer.cornerRadius = 0
            guard let image = self.textContainerView.takeScreenshot() else {
                return
            }
            self.textContainerView.layer.cornerRadius = cornerRadius

            let activityViewController = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )
            activityViewController.popoverPresentationController?.sourceView = self.view

            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}

extension FontDetailsViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.textColor == Constants.placeholderTextColor {
            textView.text = nil
            textView.textColor = Colors.blackAndWhite
        }

        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.placeholderText
            textView.textColor = Constants.placeholderTextColor
        }
    }
}

private extension LinearGradient {

    static let glass: LinearGradient = LinearGradient(
        direction: CGPoint(x: 0, y: 1),
        locations: [0, 1],
        colors: [Colors.glassBackgroundTop, Colors.glassBackgroundBottom]
    )
}

private enum Constants {

    static let containerHorziontalMargins: CGFloat = 16
    static let contentInsets: UIEdgeInsets = .init(vertical: 24, horizontal: 16)
    static let textInsets: UIEdgeInsets = .init(vertical: 12, horizontal: 16)
    static let textViewMinimumHeight: CGFloat = 44.0

    static let containerCornerRadius: CGFloat = 16.0

    static let placeholderText: String = "Quick brown fox jumps over the lazy dog"
    static let placeholderTextColor: UIColor = Colors.blackAndWhite.withAlphaComponent(0.5)
    static let initialFontSize: CGFloat = 36.0
    static let initialFontAlignment: NSTextAlignment = .center

    static let exportImageName: String = "square.and.arrow.up"
}
