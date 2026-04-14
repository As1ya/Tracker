//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Анастасия Федотова on 11.04.2026.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()

    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()
    private var completedTrackerIDs: Set<UUID> = []
    
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
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
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
        imageView.image = UIImage(named: "star")
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .trWhite
        
        trackerCategoryStore.delegate = self
        trackerRecordStore.delegate = self
        trackerStore.delegate = self
        
        setupNavigationBar()
        setupViews()
        reloadData()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
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
    
    private func setupViews() {
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
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let selectionVC = TrackerTypeSelectionViewController()
        selectionVC.delegate = self
        present(selectionVC, animated: true)
    }
    
    @objc private func dateChanged() {
        currentDate = datePicker.date
        reloadData()
    }
    
    // MARK: - Core Logic
    private func reloadData() {
        do {
            categories = try trackerCategoryStore.fetchAllCategories()
            completedTrackers = try trackerRecordStore.fetchAllRecords()
        } catch {
            print("Ошибка загрузки данных из Core Data: \(error)")
            categories = []
            completedTrackers = []
        }

        let filterText = searchController.searchBar.text?.lowercased() ?? ""
        
        let weekday = currentWeekDay()
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let containsText = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
                let containsDay = tracker.schedule.contains(weekday)
                return containsText && containsDay
            }
            if trackers.isEmpty { return nil }
            return TrackerCategory(title: category.title, trackers: trackers)
        }
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
        updateCompletedTrackerIDs()
    }
    
    private func updateCompletedTrackerIDs() {
        let todayRecordIDs = completedTrackers
            .filter { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
            .map { $0.trackerId }
        completedTrackerIDs = Set(todayRecordIDs)
    }
    
    private func currentWeekDay() -> WeekDay {
        let component = Calendar.current.component(.weekday, from: currentDate)
        return WeekDay(rawValue: component) ?? .monday
    }
    
    private func updatePlaceholderVisibility() {
        let isEmpty = visibleCategories.isEmpty
        collectionView.isHidden = isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        
        if isEmpty {
            let isSearchEmpty = searchController.searchBar.text?.isEmpty ?? true
            if isSearchEmpty {
                placeholderImageView.image = UIImage(named: "star")
                placeholderLabel.text = "Что будем отслеживать?"
            } else {
                placeholderImageView.image = UIImage(systemName: "magnifyingglass")
                placeholderLabel.text = "Ничего не найдено"
            }
        }
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        return completedTrackerIDs.contains(id)
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        reloadData()
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
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
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
        
        do {
            if isTrackerCompletedToday(id: tracker.id) {
                try trackerRecordStore.removeRecord(trackerId: tracker.id, date: currentDate)
            } else {
                try trackerRecordStore.addRecord(trackerId: tracker.id, date: currentDate)
            }
        } catch {
            print("Ошибка при обновлении записи выполнения: \(error)")
        }
        
        // Data will refresh via TrackerRecordStoreDelegate
    }
}

// MARK: - TrackerCreationDelegate
extension TrackersViewController: TrackerCreationDelegate {
    func didCreateTracker(_ tracker: Tracker, category: String) {
        do {
            let categoryCoreData = try trackerCategoryStore.fetchOrCreateCategory(title: category)
            try trackerStore.addTracker(tracker, to: categoryCoreData)
        } catch {
            print("Ошибка при создании трекера: \(error)")
        }
        dismiss(animated: true)
    }
}

// MARK: - Store Delegates
extension TrackersViewController: TrackerCategoryStoreDelegate, TrackerRecordStoreDelegate, TrackerStoreDelegate {
    func trackerCategoryStoreDidUpdate() {
        reloadData()
    }
    
    func trackerRecordStoreDidUpdate() {
        reloadData()
    }
    
    func trackerStoreDidUpdate() {
        reloadData()
    }
}
