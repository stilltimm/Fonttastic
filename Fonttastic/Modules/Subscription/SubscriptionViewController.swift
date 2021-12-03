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

    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.image = UIImage(named: "subscription-header-image")
        return imageView
    }()
    private let headerTitle: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textMajor
        label.font = UIFont(name: "Georgia-Bold", size: 30) ?? UIFont.systemFont(ofSize: 30, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = Strings.subscriptionHeaderTitle
        return label
    }()
    private let headerSubtitle: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textMinor
        label.font = UIFont(name: "AvenirNext", size: 16) ?? UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = Strings.subscriptionHeaderSubtitle
        return label
    }()
    private let actionButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.subscriptionActionButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 24)
        button.titleLabel?.textColor = UIColor.white
        button.backgroundColor = Colors.brandMainLight
        button.clipsToBounds = false
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
            identifier: "com.romandegtyarev.fonttastic.subscription.weekly",
            title: "1 неделя",
            price: Price(value: 99, currency: .rub),
            strikethroughPrice: nil
        ),
        SubscriptionItemModel(
            identifier: "com.romandegtyarev.fonttastic.subscription.monthly",
            title: "1 месяц",
            price: Price(value: 169, currency: .rub),
            strikethroughPrice: Price(value: 400, currency: .rub)
        )
    ]

    // MARK: - Internal Instance Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.backgroundMain

        setupNavigationBar()
        setupLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        actionButton.layer.applyShadow(actionButtonShadow)
    }

    // MARK: - Private Instance Methods

    private func setupNavigationBar() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = nil
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.setLeftBarButtonItems(
            [
                UIBarButtonItem(
                    title: Strings.subscriptionNavigationItemRestoreActionTitle,
                    style: UIBarButtonItem.Style.plain,
                    target: self,
                    action: #selector(self.handleRestoreAction)
                ),
                UIBarButtonItem(
                    title: Strings.subscriptionNavigationItemTermsActionTitle,
                    style: UIBarButtonItem.Style.plain,
                    target: self,
                    action: #selector(self.handleTermsAction)
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

    private func setupLayout() {
        subscriptionItemViews = subscriptionItems.map { SubscriptionItemView(model: $0) }

        guard
            let firstSubscriptionItemView = subscriptionItemViews.first,
            let lastSubscriptionItemView = subscriptionItemViews.last
        else {
            logger.log("subscriptionItemViews is empty", level: .error)
            return
        }

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
                subscriptionItem.top == previousItem.bottom + Constants.subItemSpacing
            }
        }

        constrain(
            view,
            headerImageView,
            headerTitle,
            headerSubtitle,
            actionButton,
            firstSubscriptionItemView,
            lastSubscriptionItemView
        ) { view, headerImage, headerTitle, headerSubtitle, actionButton, firstSubItem, lastSubItem in
            headerImage.left == view.left
            headerImage.right == view.right
            headerImage.top == view.safeAreaLayoutGuide.top + Constants.edgeInsets.top
            headerImage.bottom == headerTitle.top

            headerTitle.left == view.safeAreaLayoutGuide.left + Constants.edgeInsets.left
            headerTitle.right == view.safeAreaLayoutGuide.right - Constants.edgeInsets.right

            headerSubtitle.left == view.safeAreaLayoutGuide.left + Constants.edgeInsets.left
            headerSubtitle.right == view.safeAreaLayoutGuide.right - Constants.edgeInsets.right
            headerSubtitle.top == headerTitle.bottom + Constants.titleToSubtitleSpacing

            firstSubItem.top == headerSubtitle.bottom + Constants.edgeInsets.left
            lastSubItem.bottom == actionButton.top - Constants.subItemsToActionButtonSpacing

            actionButton.left == view.safeAreaLayoutGuide.left + Constants.edgeInsets.left
            actionButton.right == view.safeAreaLayoutGuide.right - Constants.edgeInsets.right
            actionButton.bottom == view.safeAreaLayoutGuide.bottom - Constants.edgeInsets.bottom
            actionButton.height == Constants.actionButtonHeight
        }

        firstSubscriptionItemView.isSelected = true
    }

    // MARK: - Actions Handling

    @objc private func handleRestoreAction() {
        logger.log("TODO: handle restore action", level: .debug)
    }
    @objc private func handleTermsAction() {
        logger.log("TODO: handle terms action", level: .debug)
    }
    @objc private func handleCloseAction() {
        self.dismiss(animated: true)
    }
}

private enum Constants {

    static let edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
    static let titleToSubtitleSpacing: CGFloat = 8
    static let subItemSpacing: CGFloat = 8
    static let subItemsToActionButtonSpacing: CGFloat = 16
    static let actionButtonHeight: CGFloat = 56
}
