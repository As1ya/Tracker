//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Анастасия Федотова on 15.04.2026.
//

import UIKit

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let backgroundImageName: String
    let headline: String
}

// MARK: - OnboardingPageViewController

final class OnboardingPageViewController: UIViewController {

    // MARK: - Properties

    private let page: OnboardingPage

    // MARK: - UI Elements

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: page.backgroundImageName)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var headlineLabel: UILabel = {
        let label = UILabel()
        label.text = page.headline
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    init(page: OnboardingPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(headlineLabel)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            headlineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headlineLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 64),
            headlineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Constants.defaultPadding),
            headlineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Constants.defaultPadding)
        ])
    }
}
