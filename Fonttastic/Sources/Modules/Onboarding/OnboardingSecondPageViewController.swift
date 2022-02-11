//
//  OnboardingSecondPageViewController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 06.12.2021.
//

import UIKit
import Cartography
import FonttasticTools

final class OnboardingSecondPageViewController: OnboardingPageViewController {

    // MARK: - Subviews

    private let cardPreviewImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "onboarding-second-page-card"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let appLogoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "onboarding-second-page-logo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let headingImageView1: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "onboarding-second-page-heading-1"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let headingImageView2: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "onboarding-second-page-heading-2"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let headingImageView3: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "onboarding-second-page-heading-3"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Initializers

    init() {
        super.init(
            onboardingPage: .secondAppShowcase,
            title: FonttasticStrings.Localizable.Onboarding.Page.Second.title
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Instance Properties

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true

        contentView.addSubview(cardPreviewImageView)
        contentView.addSubview(appLogoImageView)
        contentView.addSubview(headingImageView1)
        contentView.addSubview(headingImageView2)
        contentView.addSubview(headingImageView3)

        constrain(
            contentView,
            cardPreviewImageView,
            appLogoImageView,
            headingImageView1,
            headingImageView2,
            headingImageView3
        ) { content, cardPreview, appLogo, heading1, heading2, heading3 in
            // attachments sizes

            cardPreview.width == (content.width * 0.8)
            cardPreview.height == (cardPreview.width * 0.7)

            appLogo.width == cardPreview.width / 3
            appLogo.height == appLogo.width

            heading1.width == content.width * 0.6
            heading1.height == heading1.width * 0.5

            heading2.width == content.width * 0.3
            heading2.height == heading2.width

            heading3.width == content.width * 0.7
            heading3.height == heading3.width * 0.5

            // attachments positions

            cardPreview.centerX == content.centerX
            cardPreview.bottom == content.bottom - 40

            appLogo.right == cardPreview.right + 35
            appLogo.top == cardPreview.top

            heading1.left == content.left + 10
            heading1.top == content.top + 10

            heading2.right == content.right - 55
            heading2.top == heading1.top + 20

            heading3.centerX == content.centerX
            heading3.top == heading1.bottom + 10
        }
    }

    override func handleSrollViewDidScroll(_ scrollView: UIScrollView) {
        guard
            isViewLoaded,
            let window = view.window
        else { return }

        let originInWindow = view.convert(view.frame.center, to: window)
        let windowWidth = window.bounds.width
        let percentageOffsetFromWindowCenter: CGFloat = (originInWindow.x / windowWidth) - 0.5

        titleLabel.transform = CGAffineTransform(
            translationX: percentageOffsetFromWindowCenter * 40,
            y: 0
        )

        let cardScale: CGFloat = (1 - 0.1 * percentageOffsetFromWindowCenter)
        cardPreviewImageView.transform = CGAffineTransform(
            translationX: percentageOffsetFromWindowCenter * -20,
            y: percentageOffsetFromWindowCenter * 40
        ).scaledBy(x: cardScale, y: cardScale)
        appLogoImageView.transform = CGAffineTransform(
            translationX: percentageOffsetFromWindowCenter * 80,
            y: percentageOffsetFromWindowCenter * 60
        ).rotated(by: percentageOffsetFromWindowCenter * 0.4)

        headingImageView1.transform = CGAffineTransform(
            translationX: percentageOffsetFromWindowCenter * -40,
            y: percentageOffsetFromWindowCenter * 80
        ).rotated(by: percentageOffsetFromWindowCenter * 0.3)
        headingImageView2.transform = CGAffineTransform(
            translationX: percentageOffsetFromWindowCenter * -50,
            y: percentageOffsetFromWindowCenter * 70
        ).rotated(by: percentageOffsetFromWindowCenter * -0.2)
        headingImageView3.transform = CGAffineTransform(
            translationX: percentageOffsetFromWindowCenter * -40,
            y: percentageOffsetFromWindowCenter * 60
        ).rotated(by: percentageOffsetFromWindowCenter * 0.2)
    }
}
