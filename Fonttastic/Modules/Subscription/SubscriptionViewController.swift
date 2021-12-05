//
//  SubscriptionViewController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 21.11.2021.
//

import UIKit
import Cartography
import FonttasticTools

class SubscriptionViewController: UIViewController {

    // MARK: - Subviews

    private let backgroundView: UIView = {
        let imageView = UIImageView(image: Images.defaultBackground)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.image = UIImage(named: "keyboard-pro-header")
        return imageView
    }()
    private let headerTitle: UILabel = {
        let label = UILabel()
        label.textColor = Colors.blackAndWhite
        label.font = UIFont(name: "Futura-Bold", size: 36) ?? UIFont.systemFont(ofSize: 36, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = Strings.subscriptionHeaderTitle
        return label
    }()
    private let headerSubtitle: UILabel = {
        let label = UILabel()
        label.textColor = Colors.blackAndWhite
        label.font = UIFont(name: "AvenirNext-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = Strings.subscriptionHeaderSubtitle
        return label
    }()
    private let actionButton: SubscriptionActionButton = {
        let button = SubscriptionActionButton(frame: .zero)
        button.setTitle(Strings.subscriptionActionButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 24)
        button.titleLabel?.textColor = UIColor.white
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        return button
    }()
    private let actionButtonShadow = CALayer.Shadow(
        color: Colors.brandMainLight,
        alpha: 0.8,
        x: 0,
        y: 8,
        blur: 16,
        spread: -8
    )
    private var subscriptionItemViews: [SubscriptionItemView] = []

    // MARK: - Private Instance Properties

    private let subscriptionItems: [SubscriptionItemModel] = [
        SubscriptionItemModel(
            identifier: "com.romandegtyarev.fonttastic.subscription.premium.weekly",
            title: "1 week",
            price: Price(value: 0.99, currency: .dollar),
            strikethroughPrice: nil
        ),
        SubscriptionItemModel(
            identifier: "com.romandegtyarev.fonttastic.subscription.premium.monthly",
            title: "1 month",
            price: Price(value: 1.99, currency: .dollar),
            strikethroughPrice: Price(value: 4, currency: .dollar)
        )
    ]
    private var selectedSubscriptionItemID: SubscriptionItemModel.Identifier?

    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .soft)

    // MARK: - Internal Instance Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.backgroundMain

        setupNavigationBar()
        setupLayout()
        setupBusinessLogic()
    }

    // MARK: - Private Instance Methods

    private func setupNavigationBar() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = nil
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.setLeftBarButtonItems(
            [
                UIBarButtonItem(
                    title: Strings.subscriptionNavigationItemTermsActionTitle,
                    style: UIBarButtonItem.Style.plain,
                    target: self,
                    action: #selector(self.handleTermsAction)
                ),
                UIBarButtonItem(
                    title: Strings.subscriptionNavigationItemRestoreActionTitle,
                    style: UIBarButtonItem.Style.plain,
                    target: self,
                    action: #selector(self.handleRestoreAction)
                )
            ],
            animated: false
        )
        self.navigationItem.setRightBarButton(
            UIBarButtonItem(
                image: UIImage(systemName: "xmark"),
                style: .done,
                target: self,
                action: #selector(self.handleCloseAction)
            ),
            animated: false
        )
    }

    // swiftlint:disable:next function_body_length
    private func setupLayout() {
        subscriptionItemViews = subscriptionItems.map { SubscriptionItemView(model: $0) }

        guard
            let firstSubscriptionItemView = subscriptionItemViews.first,
            let lastSubscriptionItemView = subscriptionItemViews.last
        else {
            logger.log("subscriptionItemViews is empty", level: .error)
            return
        }

        view.addSubview(backgroundView)
        view.addSubview(headerImageView)
        view.addSubview(headerTitle)
        view.addSubview(headerSubtitle)
        view.addSubview(actionButton)

        headerImageView.setContentCompressionResistancePriority(
            UILayoutPriority(rawValue: 249),
            for: .vertical
        )
        headerImageView.setContentHuggingPriority(
            UILayoutPriority(rawValue: 249),
            for: .vertical
        )

        subscriptionItemViews.enumerated().forEach { i, subscriptionItemView in
            view.addSubview(subscriptionItemView)
            constrain(view, subscriptionItemView) { view, subscriptionItem in
                subscriptionItem.left == view.left + Constants.edgeInsets.left
                subscriptionItem.right == view.right - Constants.edgeInsets.right
            }

            guard let previousItemView = subscriptionItemViews[safe: i - 1] else { return }
            constrain(previousItemView, subscriptionItemView) { previousItem, subscriptionItem in
                subscriptionItem.top == previousItem.bottom + Constants.itemSpacing
            }
        }

        constrain(
            view,
            backgroundView,
            headerImageView,
            headerTitle,
            headerSubtitle,
            actionButton,
            firstSubscriptionItemView,
            lastSubscriptionItemView
        ) { view, background, headerImage, headerTitle, headerSubtitle, actionButton, firstSubItem, lastSubItem in
            background.edges == view.edges

            headerImage.left == view.left
            headerImage.right == view.right
            headerImage.top == view.safeAreaLayoutGuide.top + Constants.edgeInsets.top
            headerImage.bottom == headerTitle.top

            headerTitle.left == view.safeAreaLayoutGuide.left + Constants.edgeInsets.left
            headerTitle.right == view.safeAreaLayoutGuide.right - Constants.edgeInsets.right

            headerSubtitle.left == view.safeAreaLayoutGuide.left + Constants.edgeInsets.left
            headerSubtitle.right == view.safeAreaLayoutGuide.right - Constants.edgeInsets.right
            headerSubtitle.top == headerTitle.bottom + Constants.titleToSubtitleSpacing

            firstSubItem.top == headerSubtitle.bottom + Constants.subtitleToItemsSpacing
            lastSubItem.bottom == actionButton.top - Constants.itemsToActionButtonSpacing

            actionButton.left == view.safeAreaLayoutGuide.left + Constants.edgeInsets.left
            actionButton.right == view.safeAreaLayoutGuide.right - Constants.edgeInsets.right
            actionButton.bottom == view.safeAreaLayoutGuide.bottom - Constants.edgeInsets.bottom
            actionButton.height == Constants.actionButtonHeight
        }

        selectedSubscriptionItemID = lastSubscriptionItemView.model.identifier
        updateSelectedSubscriptionItemView()
    }

    private func setupBusinessLogic() {
        subscriptionItemViews.forEach { subscriptionItemView in
            subscriptionItemView.didSelectEvent.subscribe(self) { [weak self, weak subscriptionItemView] in
                self?.setSelectedSubscriptionItemID(subscriptionItemView?.model.identifier)
            }
        }

        actionButton.addTarget(self, action: #selector(self.handleContinueAction), for: .touchUpInside)
    }

    private func setSelectedSubscriptionItemID(_ id: SubscriptionItemModel.Identifier?) {
        impactFeedbackGenerator.impactOccurred()

        selectedSubscriptionItemID = id
        updateSelectedSubscriptionItemView()
    }

    private func updateSelectedSubscriptionItemView() {
        subscriptionItemViews.forEach { itemView in
            itemView.isSelected = (itemView.model.identifier == self.selectedSubscriptionItemID)
        }
    }

    // MARK: - Actions Handling

    @objc private func handleContinueAction() {
        impactFeedbackGenerator.impactOccurred()

        guard
            let selectedSubscriptionItemID = selectedSubscriptionItemID,
            let selectedSubscriptionItem = subscriptionItems.first(
                where: { $0.identifier == selectedSubscriptionItemID }
            )
        else { return }

        logger.log(
            "TODO: handle continue subscription action",
            description: "Selected SubscriptionItem: \(selectedSubscriptionItem)",
            level: .debug
        )
    }

    @objc private func handleRestoreAction() {
        impactFeedbackGenerator.impactOccurred()
        logger.log("TODO: handle restore action", level: .debug)
    }

    @objc private func handleTermsAction() {
        impactFeedbackGenerator.impactOccurred()
        logger.log("TODO: handle terms action", level: .debug)
    }

    @objc private func handleCloseAction() {
        self.dismiss(animated: true)
    }
}

private enum Constants {

    static let edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
    static let titleToSubtitleSpacing: CGFloat = 2
    static let subtitleToItemsSpacing: CGFloat = 36
    static let itemSpacing: CGFloat = 12
    static let itemsToActionButtonSpacing: CGFloat = 36
    static let actionButtonHeight: CGFloat = 56
}
