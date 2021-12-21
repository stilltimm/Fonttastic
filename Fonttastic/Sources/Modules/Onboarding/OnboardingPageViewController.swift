//
//  OnboardingPageViewController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 05.12.2021.
//

import UIKit
import Cartography
import FonttasticTools

protocol OnboardingPageViewControllerProtocol: AnyObject {

    var onboardingPage: OnboardingPage { get }
    var didAppearEvent: Event<OnboardingPage> { get }
    var didTapActionButtonEvent: Event<OnboardingPage> { get }

    func handleSrollViewDidScroll(_ scrollView: UIScrollView)
}
typealias OnboardingPageViewControllerType = (UIViewController & OnboardingPageViewControllerProtocol)

class OnboardingPageViewController: UIViewController, OnboardingPageViewControllerProtocol {

    // MARK: - Subviews

    let contentView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        view.backgroundColor = .clear
        return view
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0

        let fontSize: CGFloat
        switch UIScreen.main.sizeClass {
        case .small, .normal:
            fontSize = 20

        default:
            fontSize = 24
        }
        label.font = UIFont(name: "Futura-Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .bold)
        label.textColor = Colors.blackAndWhite
        return label
    }()
    let actionButton: UIButton = {
        let button = GradientButton()
        button.setTitle(FonttasticStrings.Localizable.Subscription.ActionButton.title, for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 16) ??
            UIFont.systemFont(ofSize: 16, weight: .bold)
        button.titleLabel?.textColor = UIColor.white
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        return button
    }()

    // MARK: - Instance Properties

    let onboardingPage: OnboardingPage
    let didAppearEvent = Event<OnboardingPage>()
    let didTapActionButtonEvent = Event<OnboardingPage>()

    // MARK: - Private Instance Properties

    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let rigidImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)

    // MARK: - Initializers

    init(onboardingPage: OnboardingPage, title: String) {
        self.onboardingPage = onboardingPage

        super.init(nibName: nil, bundle: nil)

        titleLabel.text = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Instance Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupBusinessLogic()

        impactFeedbackGenerator.prepare()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        impactFeedbackGenerator.impactOccurred()
        didAppearEvent.onNext(onboardingPage)
    }

    private func setupLayout() {
        view.addSubview(contentView)
        view.addSubview(titleLabel)
        view.addSubview(actionButton)

        contentView.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .vertical)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .vertical)

        constrain(view, contentView, titleLabel, actionButton) { view, content, title, actionButton in
            content.left == view.safeAreaLayoutGuide.left
            content.top == view.top
            content.right == view.safeAreaLayoutGuide.right
            content.bottom == title.top

            actionButton.bottom == view.safeAreaLayoutGuide.bottom - Constants.edgeInsets.bottom
            actionButton.left == view.safeAreaLayoutGuide.left + Constants.edgeInsets.left
            actionButton.right == view.safeAreaLayoutGuide.right - Constants.edgeInsets.right
            actionButton.height == Constants.actionButtonHeight

            title.bottom == actionButton.top - Constants.titleToActionButtonSpacing
            title.left == view.safeAreaLayoutGuide.left + Constants.edgeInsets.left
            title.right == view.safeAreaLayoutGuide.right - Constants.edgeInsets.right
        }
    }

    private func setupBusinessLogic() {
        actionButton.addTarget(self, action: #selector(self.handleActionButtonTap), for: .touchUpInside)
    }

    @objc private func handleActionButtonTap() {
        rigidImpactFeedbackGenerator.impactOccurred()
        didTapActionButtonEvent.onNext(onboardingPage)
    }

    func handleSrollViewDidScroll(_ scrollView: UIScrollView) {
        logger.log("Subclasses must override this method", level: .debug)
    }
}

private enum Constants {

    static let edgeInsets: UIEdgeInsets = UIEdgeInsets(vertical: 16, horizontal: 16)
    static let actionButtonHeight: CGFloat = 56
    static let titleToActionButtonSpacing: CGFloat = {
        switch UIScreen.main.sizeClass {
        case .small, .normal:
            return 20

        default:
            return 44
        }
    }()
}
