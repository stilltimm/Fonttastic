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
            title: "Create crazy custom fonts from any image" // TODO: Localize
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Instance Properties

    override func viewDidLoad() {
        super.viewDidLoad()

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
            heading1.top == content.top + 30

            heading2.right == content.right - 55
            heading2.top == heading1.top + 30

            heading3.centerX == content.centerX
            heading3.centerY == content.centerY - 60
        }
    }
}
