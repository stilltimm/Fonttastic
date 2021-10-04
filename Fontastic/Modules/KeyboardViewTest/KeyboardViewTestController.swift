//
//  KeyboardViewTestController.swift
//  Fontastic
//
//  Created by Timofey Surkov on 27.09.2021.
//

import UIKit
import Cartography
import FontasticKeyboard

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
    private let fontasticKeyboardView = FontasticKeyboardView()

    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Keyboard View"

        setupLayout()
    }

    // MARK: - Private Methods

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.backgroundColor = Colors.backgroundMain

        containerView.addSubview(fontasticKeyboardView)
        constrain(
            view, scrollView, containerView, fontasticKeyboardView
        ) { (view, scrollView, container, keyboard) in
            scrollView.edges == view.edges

            (container.width == view.width).priority = .required
            container.height == UIScreen.main.bounds.height

            keyboard.center == container.center
        }
    }
}
