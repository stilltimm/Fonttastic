//
//  OnboardingViewController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 05.12.2021.
//

import UIKit

class OnboardingViewController: UIPageViewController {

    init() {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Instance Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setViewControllers(
            [OnboardingFirstPageViewController()],
            direction: .forward,
            animated: false,
            completion: nil
        )

        self.dataSource = self
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let onboardingPageViewController = viewController as? OnboardingPageViewControllerType else {
            return nil
        }

        switch onboardingPageViewController.onboardingPage {
        case .firstAppShowcase:
            return OnboardingSecondPageViewController()

        case .secondAppShowcase:
            return SubscriptionViewController()

        case .subscription:
            return nil
        }
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let onboardingPageViewController = viewController as? OnboardingPageViewControllerType else {
            return nil
        }

        switch onboardingPageViewController.onboardingPage {
        case .firstAppShowcase:
            return nil

        case .secondAppShowcase:
            return OnboardingFirstPageViewController()

        case .subscription:
            return OnboardingSecondPageViewController()
        }
    }
}
