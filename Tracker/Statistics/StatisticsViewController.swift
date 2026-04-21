//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Анастасия Федотова on 09.04.2026.
//

import UIKit

// MARK: - StatisticsViewController

final class StatisticsViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let viewModel: StatisticsViewModel
    
    // MARK: - UI Components
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Resources.Constants.defaultPadding
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = true
        return stackView
    }()

    private lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Resources.Images.cryFace)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics.emptyPlaceholder", comment: "")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var statisticViews: [StatisticCardView] = (0..<4).map { _ in
        StatisticCardView()
    }
    
    // MARK: - Initialization

    init(viewModel: StatisticsViewModel = StatisticsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupNavigationBar()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reload()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .trWhite
        statisticViews.forEach { stackView.addArrangedSubview($0) }

        view.addSubview(stackView)
        view.addSubview(emptyImageView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Constants.defaultPadding),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Constants.defaultPadding),

            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: Resources.Constants.smallPadding),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = L10n.Statistics.title
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func bind() {
        viewModel.onStatisticsChange = { [weak self] items in
            guard let self else { return }
            zip(self.statisticViews, items).forEach { view, item in
                view.configure(value: item.value, title: item.title)
            }
        }

        viewModel.onEmptyStateChange = { [weak self] isEmpty in
            self?.stackView.isHidden = isEmpty
            self?.emptyImageView.isHidden = !isEmpty
            self?.emptyLabel.isHidden = !isEmpty
        }

        viewModel.onError = { [weak self] message in
            self?.showError(message: message)
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: L10n.Trackers.Alert.errorTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Trackers.Alert.ok, style: .default))
        present(alert, animated: true)
    }
}
