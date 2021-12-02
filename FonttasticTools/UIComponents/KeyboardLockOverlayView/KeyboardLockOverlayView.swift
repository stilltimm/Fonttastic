//
//  KeyboardLockOverlayView.swift
//  FonttasticTools
//
//  Created by Timofey Surkov on 01.12.2021.
//

import UIKit
import Cartography

public class KeyboardLockOverlayView: UIControl {

    // MARK: - Subviews

    private let lockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "lock.circle.fill")
        imageView.isUserInteractionEnabled = false
        imageView.tintColor = Colors.blackAndWhite
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
        label.text = Strings.keyboardLockedStateTitle
        label.textColor = Colors.blackAndWhite
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        return label
    }()
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext", size: 18) ?? UIFont.systemFont(ofSize: 18)
        label.text = Strings.keyboardLockedStateMessage
        label.textColor = Colors.blackAndWhite
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        return label
    }()
    private let openAppContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.brandMainLight
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .continuous
        view.isUserInteractionEnabled = false
        return view
    }()
    private let openAppLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
        label.text = Strings.keyboardLockedStateOpenAppButtonTitle
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.isUserInteractionEnabled = false
        return label
    }()

    // MARK: - Public Instance Properties

    public let didTapEvent = FonttasticTools.Event<Void>()

    public override var isHighlighted: Bool {
        didSet {
            UIView.animate(
                withDuration: 0.1,
                delay: 0.0,
                options: .curveEaseOut
            ) {
                self.openAppContainer.transform = self.isHighlighted ?
                CGAffineTransform(scaleX: 0.95, y: 0.95) :
                    .identity
            }
        }
    }

    // MARK: - Private Instance Properties

    private var portraitOrientationConstraints: [NSLayoutConstraint] = []
    private var landscapeOrientationConstraints: [NSLayoutConstraint] = []
    private var titleHeightConstraint: NSLayoutConstraint?
    private var messageHeightConstraint: NSLayoutConstraint?

    // MARK: - Initializers

    public init() {
        super.init(frame: .zero)

        configureLayout()
        setupTapHandling()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Instance Methods

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()

        updateTitleAndMessageHeightConstraints()
    }

    public func adaptToOrientationChange(isPortrait: Bool) {
        titleLabel.textAlignment = isPortrait ? .center : .left
        messageLabel.textAlignment = isPortrait ? .center : .left

        if isPortrait {
            NSLayoutConstraint.deactivate(landscapeOrientationConstraints)
            NSLayoutConstraint.activate(portraitOrientationConstraints)
        } else {
            NSLayoutConstraint.deactivate(portraitOrientationConstraints)
            NSLayoutConstraint.activate(landscapeOrientationConstraints)
        }

        updateTitleAndMessageHeightConstraints()
    }

    // MARK: - Private Instance Methods

    private func configureLayout() {
        addSubview(lockImageView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(openAppContainer)
        openAppContainer.addSubview(openAppLabel)

        constrain(
            self, lockImageView, titleLabel, messageLabel, openAppContainer, openAppLabel
        ) { view, lockImage, title, message, openAppContainer, openAppLabel in
            // lockImage / default
            lockImage.width == Constants.lockIconSize.width
            lockImage.height == Constants.lockIconSize.height
            // lockImage / portrait
            portraitOrientationConstraints.append(lockImage.centerX == view.centerX)
            portraitOrientationConstraints.append(lockImage.bottom == title.top - Constants.lockImageToTitleSpacing)
            // lockImage / landscape
            landscapeOrientationConstraints.append(lockImage.centerY == view.centerY)
            landscapeOrientationConstraints.append(lockImage.left == view.left + Constants.edgeInsets.left)
            landscapeOrientationConstraints.append(lockImage.centerY == view.centerY)

            // title / default
            titleHeightConstraint = (title.height == 0)
            title.right == view.right - Constants.edgeInsets.right
            // title / portrait
            portraitOrientationConstraints.append(title.left == view.left + Constants.edgeInsets.left)
            portraitOrientationConstraints.append(title.bottom == view.centerY)
            // title / landscape
            landscapeOrientationConstraints.append(title.left == lockImage.right + Constants.edgeInsets.left)

            // message / default
            message.left == title.left
            message.right == title.right
            message.top == title.bottom + Constants.titleToMessageSpacing
            messageHeightConstraint = (message.height == 0)
            // message / landscape
            landscapeOrientationConstraints.append(message.bottom == view.centerY)

            // openAppContainer / default
            openAppContainer.top == message.bottom + Constants.messageToButtonSpacing
            // openAppContainer / portrait
            portraitOrientationConstraints.append(openAppContainer.centerX == view.centerX)
            // openAppContainer / landscape
            landscapeOrientationConstraints.append(openAppContainer.left == title.left)

            // openAppLabel / default
            openAppLabel.edges == openAppContainer.edges.inseted(by: Constants.openAppButtonInsets)
        }

        adaptToOrientationChange(isPortrait: UIScreen.main.isPortrait)
    }

    private func updateTitleAndMessageHeightConstraints() {
        var boundingWidth = UIScreen.main.bounds.width
        - Constants.edgeInsets.horizontalSum
        - safeAreaInsets.horizontalSum
        if !UIScreen.main.isPortrait {
            boundingWidth -= Constants.edgeInsets.left
            boundingWidth -= Constants.lockIconSize.width
        }
        let boundingSize = CGSize(width: boundingWidth, height: .greatestFiniteMagnitude)

        titleHeightConstraint?.constant = ceil(titleLabel.sizeThatFits(boundingSize).height)
        messageHeightConstraint?.constant = ceil(messageLabel.sizeThatFits(boundingSize).height)
    }

    private func setupTapHandling() {
        self.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
    }

    @objc private func handleTap() {
        didTapEvent.onNext(())
    }
}

private enum Constants {

    static let lockIconSize: CGSize = CGSize(width: 96, height: 96)
    static let edgeInsets: UIEdgeInsets = UIEdgeInsets(vertical: 16, horizontal: 16)
    static let openAppButtonInsets: UIEdgeInsets = UIEdgeInsets(vertical: 12, horizontal: 16)

    static let lockImageToTitleSpacing: CGFloat = 8
    static let titleToMessageSpacing: CGFloat = 4
    static let messageToButtonSpacing: CGFloat = 16
}
