//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Анастасия Федотова on 11.04.2026.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: TrackersViewModel

    private var visibleCategories: [TrackerCategory] = []
    private var currentDate: Date = Date()
    
    // MARK: - UI Elements
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.widthAnchor.constraint(equalToConstant: 120).isActive = true
        return picker
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = Resources.Constants.defaultPadding
        layout.sectionInset = UIEdgeInsets(top: Resources.Constants.mediumPadding, left: Resources.Constants.defaultPadding, bottom: Resources.Constants.defaultPadding, right: Resources.Constants.defaultPadding)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .trWhite
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeader.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Resources.Images.emptyTrackers)
        imageView.tintColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    init(viewModel: TrackersViewModel = TrackersViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .trWhite
        
        setupNavigationBar()
        setupViews()
        bind()
    }
    
    // MARK: - Setup
    
    private func bind() {
        viewModel.onVisibleCategoriesChange = { [weak self] categories in
            self?.visibleCategories = categories
            self?.collectionView.reloadData()
        }
        
        viewModel.onEmptyStateChange = { [weak self] isEmpty, isSearch in
            self?.updatePlaceholder(isEmpty: isEmpty, isSearch: isSearch)
        }

        viewModel.onError = { [weak self] message in
            self?.showError(message: message)
        }
    }
    
    private func setupNavigationBar() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: Resources.Images.plus),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        addButton.tintColor = .label
        navigationItem.leftBarButtonItem = addButton
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let selectionVC = TrackerTypeSelectionViewController()
        selectionVC.delegate = self
        present(selectionVC, animated: true)
    }
    
    @objc private func dateChanged() {
        currentDate = datePicker.date
        viewModel.updateDate(currentDate)
    }
    
    // MARK: - Helpers
    
    private func updatePlaceholder(isEmpty: Bool, isSearch: Bool) {
        collectionView.isHidden = isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        
        if isEmpty {
            if isSearch {
                placeholderImageView.image = UIImage(systemName: Resources.Images.searchPrefix)
                placeholderLabel.text = "Ничего не найдено"
            } else {
                placeholderImageView.image = UIImage(named: Resources.Images.emptyTrackers)
                placeholderLabel.text = "Что будем отслеживать?"
            }
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UI Configuration Extension

private extension TrackersViewController {
    func setupViews() {
        view.addSubview(collectionView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: Resources.Constants.iconSize),
            placeholderImageView.heightAnchor.constraint(equalToConstant: Resources.Constants.iconSize),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: Resources.Constants.smallPadding),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}


extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.updateSearchText(searchController.searchBar.text)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let isCompletedToday = viewModel.isCompletedToday(id: tracker.id)
        let completedDays = viewModel.completedDays(id: tracker.id)
        
        cell.delegate = self
        cell.configure(with: tracker, isCompletedToday: isCompletedToday, completedDays: completedDays)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerCategoryHeader.identifier, for: indexPath) as? TrackerCategoryHeader else {
            return UICollectionReusableView()
        }
        view.titleLabel.text = visibleCategories[indexPath.section].title
        return view
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - 16 * 2 - 9
        let cellWidth = availableWidth / 2
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let pinTitle = tracker.isPinned ? "Открепить" : "Закрепить"
            let pinAction = UIAction(title: pinTitle) { _ in
                self?.viewModel.togglePin(for: tracker)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                self?.showDeleteConfirmation(tracker)
            }
            
            return UIMenu(title: "", children: [pinAction, deleteAction])
        }
    }
    
    private func showDeleteConfirmation(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: "Уверены, что хотите удалить трекер?",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteTracker(tracker)
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidTapCompleteButton(_ cell: TrackerCell) {
        let today = Date()
        let startOfToday = Calendar.current.startOfDay(for: today)
        let startOfSelectedDate = Calendar.current.startOfDay(for: currentDate)
        
        if startOfSelectedDate > startOfToday {
            return // Cannot complete a tracker for a future date
        }
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        viewModel.toggleCompletion(for: tracker)
    }
}

// MARK: - TrackerCreationDelegate
extension TrackersViewController: TrackerCreationDelegate {
    func didCreateTracker(_ tracker: Tracker, category: String) {
        viewModel.addTracker(tracker, to: category)
        dismiss(animated: true)
    }
}
