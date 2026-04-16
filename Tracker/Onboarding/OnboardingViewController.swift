//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Анастасия Федотова on 15.04.2026.
//

import UIKit

// MARK: - OnboardingViewController (UIPageViewController container)

final class OnboardingViewController: UIViewController {

    // MARK: - Pages Data

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            backgroundImageName: Resources.Images.onboarding1,
            headline: "Отслеживайте только\nто, что хотите"
        ),
        OnboardingPage(
            backgroundImageName: Resources.Images.onboarding2,
            headline: "Даже если это\nне литры воды и йога"
        )
    ]

    // MARK: - Child Controllers

    private lazy var pageControllers: [OnboardingPageViewController] = {
        pages.map { OnboardingPageViewController(page: $0) }
    }()

    // MARK: - UI Elements

    private lazy var pageViewController: UIPageViewController = {
        let pvc = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [.interPageSpacing: 16]
        )
        pvc.dataSource = self
        pvc.delegate = self
        return pvc
    }()

    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = pages.count
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = .black
        pc.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.25)
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    private lazy var ctaButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Вот это технологии!"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .black
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 24, bottom: 18, trailing: 24)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(ctaTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        setupOverlayControls()
    }

    // MARK: - Setup

    private func setupPageViewController() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.frame = view.bounds
        pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pageViewController.didMove(toParent: self)

        pageViewController.setViewControllers(
            [pageControllers[0]],
            direction: .forward,
            animated: false,
            completion: nil
        )
    }

    private func setupOverlayControls() {
        view.addSubview(pageControl)
        view.addSubview(ctaButton)

        NSLayoutConstraint.activate([
            // Элемент управления страницей находится над кнопкой
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: ctaButton.topAnchor, constant: -Resources.Constants.mediumPadding),

            // CTA button прикрепленная к safe area bottom
            ctaButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Constants.extraLargePadding),
            ctaButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Constants.extraLargePadding),
            ctaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Resources.Constants.defaultPadding)
        ])
    }

    // MARK: - Actions

    @objc private func ctaTapped() {
        UserDefaults.standard.set(true, forKey: Resources.UserDefaultsKeys.hasSeenOnboarding)
        
        guard let window = view.window else { return }
            
        window.rootViewController = TabBarController()
        window.makeKeyAndVisible()
        
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard
            let current = viewController as? OnboardingPageViewController,
            let index = pageControllers.firstIndex(of: current),
            index > 0
        else { return nil }
        return pageControllers[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard
            let current = viewController as? OnboardingPageViewController,
            let index = pageControllers.firstIndex(of: current),
            index < pageControllers.count - 1
        else { return nil }
        return pageControllers[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard
            completed,
            let current = pageViewController.viewControllers?.first as? OnboardingPageViewController,
            let index = pageControllers.firstIndex(of: current)
        else { return }

        pageControl.currentPage = index
    }
}
