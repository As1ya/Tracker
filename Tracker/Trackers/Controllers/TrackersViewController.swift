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
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.Filters.title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 16
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
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
        label.text = L10n.Trackers.EmptyPlaceholder.noTrackers
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
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.report(event: .open, screen: .main)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.report(event: .close, screen: .main)
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
        
        viewModel.onDateDidReset = { [weak self] in
            guard let self = self else { return }
            self.datePicker.date = Date()
            self.currentDate = Date()
        }
    }
    
    private func setupNavigationBar() {
        title = L10n.Trackers.title
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
        searchController.searchBar.placeholder = L10n.Trackers.Search.placeholder
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        AnalyticsService.report(event: .click, screen: .main, item: .addTrack)
        let selectionVC = TrackerTypeSelectionViewController()
        selectionVC.delegate = self
        present(selectionVC, animated: true)
    }
    
    @objc private func filterButtonTapped() {
        AnalyticsService.report(event: .click, screen: .main, item: .filter)
        let vc = FiltersViewController(selectedFilter: .all) // We should probably store the current filter in VC too or get from VM
        vc.delegate = self
        present(vc, animated: true)
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
        
        filterButton.isHidden = isEmpty && !isSearch
        
        if isEmpty {
            if isSearch {
                placeholderImageView.image = UIImage(named: Resources.Images.face)
                placeholderLabel.text = L10n.Trackers.EmptyPlaceholder.notFound
            } else {
                placeholderImageView.image = UIImage(named: Resources.Images.emptyTrackers)
                placeholderLabel.text = L10n.Trackers.EmptyPlaceholder.noTrackers
            }
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: L10n.Trackers.Alert.errorTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Trackers.Alert.ok, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UI Configuration Extension

private extension TrackersViewController {
    func setupViews() {
        view.addSubview(collectionView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(filterButton)
        
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
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
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
            let editAction = UIAction(title: L10n.Trackers.ContextMenu.edit) { _ in
                AnalyticsService.report(event: .click, screen: .main, item: .edit)
                self?.showEditTracker(tracker)
            }

            let pinTitle = tracker.isPinned ? L10n.Trackers.ContextMenu.unpin : L10n.Trackers.ContextMenu.pin
            let pinAction = UIAction(title: pinTitle) { _ in
                self?.viewModel.togglePin(for: tracker)
            }
            
            let deleteAction = UIAction(title: L10n.Trackers.ContextMenu.delete, attributes: .destructive) { _ in
                AnalyticsService.report(event: .click, screen: .main, item: .delete)
                self?.showDeleteConfirmation(tracker)
            }
            
            return UIMenu(title: "", children: [editAction, pinAction, deleteAction])
        }
    }
    
    private func showDeleteConfirmation(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: L10n.Trackers.Alert.deleteConfirmationTitle,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: L10n.Trackers.ContextMenu.delete, style: .destructive) { [weak self] _ in
            self?.viewModel.deleteTracker(tracker)
        }
        
        let cancelAction = UIAlertAction(title: L10n.Trackers.Alert.cancel, style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }

    private func showEditTracker(_ tracker: Tracker) {
        guard let category = viewModel.categoryTitle(for: tracker.id) else {
            showError(message: L10n.CoreData.unknownCategory)
            return
        }

        let viewController = TrackerCreationViewController(
            isHabit: tracker.isHabit,
            mode: .edit(original: tracker, category: category)
        )
        viewController.delegate = self
        present(viewController, animated: true)
    }
}

// MARK: - FiltersViewControllerDelegate
extension TrackersViewController: FiltersViewControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        viewModel.updateFilter(filter)
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidTapCompleteButton(_ cell: TrackerCell) {
        AnalyticsService.report(event: .click, screen: .main, item: .track)
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

    func didUpdateTracker(_ tracker: Tracker, category: String) {
        viewModel.updateTracker(tracker, in: category)
        dismiss(animated: true)
    }
}
