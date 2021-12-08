//
//  OnboardingViewController.swift
//  Fonttastic
//
//  Created by Timofey Surkov on 05.12.2021.
//

import UIKit
import FonttasticTools

class OnboardingViewController: UIPageViewController {

    // MARK: - Private Instance Properties

    private let appStatusService: AppStatusService = DefaultAppStatusService.shared

    private var scrollView: UIScrollView? {
        for subview in view.subviews {
            guard let firstScrollView = subview as? UIScrollView else { continue }
            return firstScrollView
        }

        return nil
    }

    // MARK: - Initializers

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

        self.dataSource = self
        self.delegate = self
        scrollView?.delegate = self

        self.isModalInPresentation = true

        let firstPageViewController = makeOnboardingPageViewController(for: .firstAppShowcase)
        self.setViewControllers(
            [firstPageViewController],
            direction: .forward,
            animated: false,
            completion: nil
        )
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {}

extension OnboardingViewController: UIPageViewControllerDataSource {

    // MARK: - Internal Instance Methods

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard
            let onboardingPageViewController = viewController as? OnboardingPageViewControllerType,
            let nextPage = onboardingPageViewController.onboardingPage.next
        else { return nil }

        let nextOnboardingPageViewController = makeOnboardingPageViewController(for: nextPage)
        configureOnboardingPageViewController(nextOnboardingPageViewController)

        return nextOnboardingPageViewController
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard
            let onboardingPageViewController = viewController as? OnboardingPageViewControllerType,
            let prevPage = onboardingPageViewController.onboardingPage.prev
        else { return nil }

        let prevOnboardingPageViewController = makeOnboardingPageViewController(for: prevPage)
        configureOnboardingPageViewController(prevOnboardingPageViewController)

        return prevOnboardingPageViewController
    }

    // MARK: - Private Instance Methods

    private func makeOnboardingPageViewController(
        for onboardingPage: OnboardingPage
    ) -> OnboardingPageViewControllerType {
        let onboardingPageViewController: OnboardingPageViewControllerType
        switch onboardingPage {
        case .firstAppShowcase:
            onboardingPageViewController = OnboardingFirstPageViewController()

        case .secondAppShowcase:
            onboardingPageViewController = OnboardingSecondPageViewController()

        case .subscription:
            onboardingPageViewController = SubscriptionViewController()
        }
        configureOnboardingPageViewController(onboardingPageViewController)

        return onboardingPageViewController
    }

    private func configureOnboardingPageViewController(_ viewController: OnboardingPageViewControllerType) {
        viewController.didTapActionButtonEvent.subscribe(self) { [weak self] onboardingPage in
            guard let self = self else { return }

            if let nextPage = onboardingPage.next {
                let viewController = self.makeOnboardingPageViewController(for: nextPage)
                self.setViewControllers(
                    [viewController],
                    direction: .forward,
                    animated: true,
                    completion: nil
                )
            }

            logger.log(
                "TODO: log action button tapped at onboarding page \"\(onboardingPage)\"",
                level: .info
            )

            if onboardingPage == .subscription {
                self.dismiss(animated: true, completion: nil)
                self.appStatusService.setOnboardingComplete()
            }
        }

        viewController.didAppearEvent.subscribe(self) { [weak self] onboardingPage in
            logger.log(
                "TODO: log onboarding page \"\(onboardingPage)\" did appear",
                level: .info
            )
        }
    }
}

extension OnboardingViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.children.forEach { childViewController in
            guard
                let onboardingPageViewController = childViewController as? OnboardingPageViewControllerType
            else { return }

            onboardingPageViewController.handleSrollViewDidScroll(scrollView)
        }
    }
}
