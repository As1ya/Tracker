//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Анастасия Федотова on 15.04.2026.
//

import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

final class CategoryViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: CategoryViewControllerDelegate?
    private let viewModel: CategoryViewModel
    private var rows: [CategoryViewModel.CategoryCellViewModel] = []
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Category.title
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.layer.cornerRadius = Resources.Constants.cornerRadius
        table.backgroundColor = .clear
        table.separatorInset = UIEdgeInsets(top: 0, left: Resources.Constants.defaultPadding, bottom: 0, right: Resources.Constants.defaultPadding)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Resources.Images.emptyTrackers)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Category.EmptyPlaceholder.text
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.Category.addCategoryButton, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .trBlack
        button.setTitleColor(.trWhite, for: .normal)
        button.layer.cornerRadius = Resources.Constants.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    init(selectedCategory: String?) {
        self.viewModel = CategoryViewModel(selectedCategory: selectedCategory)
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
        bind()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .trWhite
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Constants.defaultPadding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Constants.defaultPadding),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -Resources.Constants.defaultPadding),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            placeholderImageView.widthAnchor.constraint(equalToConstant: Resources.Constants.iconSize),
            placeholderImageView.heightAnchor.constraint(equalToConstant: Resources.Constants.iconSize),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: Resources.Constants.smallPadding),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Constants.largePadding),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Constants.largePadding),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Resources.Constants.defaultPadding),
            addCategoryButton.heightAnchor.constraint(equalToConstant: Resources.Constants.buttonHeight)
        ])
    }
    
    private func bind() {
        viewModel.onRowsChange = { [weak self] rows in
            self?.rows = rows
            self?.updateUI()
        }
        viewModel.onError = { [weak self] message in
            self?.showError(message: message)
        }
        rows = viewModel.rowViewModels
        updateUI()
    }
    
    private func updateUI() {
        let isEmpty = rows.isEmpty
        tableView.isHidden = isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func addCategoryTapped() {
        let vc = NewCategoryViewController(existingTitles: Set(rows.map(\.title)))
        vc.delegate = self
        present(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }

        guard let row = viewModel.row(at: indexPath.row) else {
            return cell
        }

        cell.configure(with: row.title, isSelected: row.isSelected, isFirst: row.isFirst, isLast: row.isLast)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = viewModel.row(at: indexPath.row) else { return }
        viewModel.selectCategory(title: row.title)
        delegate?.didSelectCategory(row.title)
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let row = viewModel.row(at: indexPath.row) else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(title: L10n.Category.ContextMenu.edit) { _ in
                let vc = NewCategoryViewController(
                    mode: .edit(row.title),
                    existingTitles: Set(self?.rows.map(\.title) ?? [])
                )
                vc.delegate = self
                self?.present(vc, animated: true)
            }
            
            let deleteAction = UIAction(title: L10n.Category.ContextMenu.delete, attributes: .destructive) { _ in
                self?.showDeleteConfirmation(for: row.title)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    private func showDeleteConfirmation(for title: String) {
        let alert = UIAlertController(
            title: L10n.Category.Alert.deleteConfirmationTitle,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: L10n.Category.ContextMenu.delete, style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(title: title)
        }
        
        let cancelAction = UIAlertAction(title: L10n.Trackers.Alert.cancel, style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: L10n.Trackers.Alert.errorTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Trackers.Alert.ok, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - NewCategoryViewControllerDelegate
extension CategoryViewController: NewCategoryViewControllerDelegate {
    func didCreateCategory(_ title: String) {
        viewModel.addCategory(title: title)
    }

    func didEditCategory(oldTitle: String, newTitle: String) {
        viewModel.editCategory(oldTitle: oldTitle, newTitle: newTitle)
    }
}
