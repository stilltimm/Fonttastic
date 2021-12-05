//
//  OnboardingFirstPageViewController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 05.12.2021.
//

import UIKit
import Cartography
import FonttasticTools

final class OnboardingFirstPageViewController: OnboardingPageViewController {

    // MARK: - Subviews

    private let iphoneImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "onboarding-first-page-iphone"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let smileImageView1: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "onboarding-first-page-smile-1"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let smileImageView2: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "onboarding-first-page-smile-2"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let smileImageView3: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "onboarding-first-page-smile-3"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let headingImageView1: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "onboarding-first-page-heading-1"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let headingImageView2: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "onboarding-first-page-heading-2"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let headingImageView3: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "onboarding-first-page-heading-3"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Initializers

    init() {
        super.init(
            onboardingPage: .firstAppShowcase,
            title: "Amazing collection of custom typefaces" // TODO: Localize
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Instance Properties

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.addSubview(headingImageView1)
        contentView.addSubview(headingImageView3)
        contentView.addSubview(smileImageView2)
        contentView.addSubview(smileImageView3)
        contentView.addSubview(iphoneImageView)
        contentView.addSubview(headingImageView2)
        contentView.addSubview(smileImageView1)

        constrain(
            contentView,
            iphoneImageView,
            smileImageView1,
            smileImageView2,
            smileImageView3,
            headingImageView1,
            headingImageView2,
            headingImageView3
        ) { content, iphone, smile1, smile2, smile3, heading1, heading2, heading3 in
            iphone.height == (content.height * 0.8)
            iphone.width == (iphone.height / 2.08)
            iphone.center == content.center

            // attachments sizes

            smile1.width == Constants.smile1Size.width
            smile1.height == Constants.smile1Size.height

            smile2.width == Constants.smile2Size.width
            smile2.height == Constants.smile2Size.height

            smile3.width == Constants.smile3Size.width
            smile3.height == Constants.smile3Size.height

            heading1.width == Constants.heading1Size.width
            heading1.height == Constants.heading1Size.height

            heading2.width == Constants.heading2Size.width
            heading2.height == Constants.heading2Size.height

            heading3.width == Constants.heading3Size.width
            heading3.height == Constants.heading3Size.height

            // attachments positions

            smile1.left == iphone.left - Constants.smile1Size.width * 0.5
            smile1.top == iphone.top + 70

            smile2.left == iphone.left - Constants.smile2Size.width * 0.7
            smile2.bottom == iphone.bottom - 100

            smile3.left == iphone.right - Constants.smile3Size.width * 0.25
            smile3.bottom == iphone.bottom - 65

            heading1.left == iphone.right - 0.3 * Constants.heading1Size.width
            heading1.top == iphone.top + 55

            heading2.left == iphone.right - 0.3 * Constants.heading2Size.width
            heading2.centerY == iphone.centerY + 45

            heading3.left == iphone.left - 0.7 * Constants.heading3Size.width
            heading3.centerY == iphone.centerY - 30
        }
    }
}

private enum Constants {

    static let smile1Size: CGSize = CGSize(width: 84, height: 84)
    static let smile2Size: CGSize = CGSize(width: 139, height: 139)
    static let smile3Size: CGSize = CGSize(width: 99, height: 99)
    static let heading1Size: CGSize = CGSize(width: 76, height: 76)
    static let heading2Size: CGSize = CGSize(width: 50, height: 55)
    static let heading3Size: CGSize = CGSize(width: 71, height: 45)
}
