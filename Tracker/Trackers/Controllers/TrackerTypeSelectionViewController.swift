//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Анастасия Федотова on 11.04.2026.
//

import UIKit

// MARK: - TrackerCreationDelegate Protocol
protocol TrackerCreationDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, category: String)
    func didUpdateTracker(_ tracker: Tracker, category: String)
}

// MARK: - TrackerTypeSelectionViewController
final class TrackerTypeSelectionViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: TrackerCreationDelegate?
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.TrackerSelection.title
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.TrackerSelection.habitButton, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .trBlack
        button.setTitleColor(.trWhite, for: .normal)
        button.layer.cornerRadius = Resources.Constants.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(habitTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var eventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.TrackerSelection.eventButton, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .trBlack
        button.setTitleColor(.trWhite, for: .normal)
        button.layer.cornerRadius = Resources.Constants.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(eventTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .trWhite
        setupViews()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(habitButton)
        view.addSubview(eventButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Constants.largePadding),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Constants.largePadding),
            habitButton.heightAnchor.constraint(equalToConstant: Resources.Constants.buttonHeight),
            
            eventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: Resources.Constants.defaultPadding),
            eventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Constants.largePadding),
            eventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Constants.largePadding),
            eventButton.heightAnchor.constraint(equalToConstant: Resources.Constants.buttonHeight)
        ])
    }
    
    // MARK: - Actions
    @objc private func habitTapped() {
        let vc = TrackerCreationViewController(isHabit: true)
        vc.delegate = delegate
        present(vc, animated: true)
    }
    
    @objc private func eventTapped() {
        let vc = TrackerCreationViewController(isHabit: false)
        vc.delegate = delegate
        present(vc, animated: true)
    }
}
