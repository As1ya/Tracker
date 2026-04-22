//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Анастасия Федотова on 19.04.2026.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

final class FiltersViewController: UIViewController {
    
    // MARK: - Delegate
    weak var delegate: FiltersViewControllerDelegate?
    
    // MARK: - Properties
    private let filters = TrackerFilter.allCases
    private var selectedFilter: TrackerFilter
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Filters.title
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .trBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        table.layer.cornerRadius = Resources.Constants.cornerRadius
        table.isScrollEnabled = false
        table.separatorInset = UIEdgeInsets(top: 0, left: Resources.Constants.defaultPadding, bottom: 0, right: Resources.Constants.defaultPadding)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Init
    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .trWhite
        setupViews()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        let tableHeight: CGFloat = CGFloat(filters.count) * 75
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Constants.defaultPadding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Constants.defaultPadding),
            tableView.heightAnchor.constraint(equalToConstant: tableHeight)
        ])
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let filter = filters[indexPath.row]
        
        cell.textLabel?.text = filter.title
        cell.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.3)
        cell.selectionStyle = .none
        
        cell.accessoryType = (filter == selectedFilter) ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = filters[indexPath.row]
        selectedFilter = filter
        tableView.reloadData()
        
        delegate?.didSelectFilter(filter)
        dismiss(animated: true)
    }
}
