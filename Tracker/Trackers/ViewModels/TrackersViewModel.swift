//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Анастасия Федотова on 15.04.2026.
//

import Foundation
import OSLog

final class TrackersViewModel {
    
    // MARK: - Properties
    
    private let trackerStore: TrackerStore
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    
    private(set) var visibleCategories: [TrackerCategory] = [] {
        didSet {
            onVisibleCategoriesChange?(visibleCategories)
            updateEmptyState()
        }
    }
    
    var onVisibleCategoriesChange: (([TrackerCategory]) -> Void)? {
        didSet {
            onVisibleCategoriesChange?(visibleCategories)
        }
    }
    
    var onEmptyStateChange: ((Bool, Bool) -> Void)? {
        didSet {
            updateEmptyState()
        }
    }
    
    var onError: ((String) -> Void)?
    
    private var currentDate: Date = Date()
    private var searchText: String?
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    // MARK: - Init
    
    init(
        trackerStore: TrackerStore = TrackerStore(),
        trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore(),
        trackerRecordStore: TrackerRecordStore = TrackerRecordStore()
    ) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        
        self.trackerStore.delegate = self
        self.trackerCategoryStore.delegate = self
        self.trackerRecordStore.delegate = self
        
        reloadData()
    }
    
    // MARK: - Public Methods
    
    func updateDate(_ date: Date) {
        currentDate = date
        reloadData()
    }
    
    func updateSearchText(_ text: String?) {
        searchText = text
        reloadData()
    }
    
    func togglePin(for tracker: Tracker) {
        do {
            try trackerStore.togglePin(for: tracker)
            reloadData()
        } catch {
            handle(error, message: "Failed to toggle pin")
        }
    }
    
    func deleteTracker(_ tracker: Tracker) {
        do {
            try trackerStore.deleteTracker(tracker)
            reloadData()
        } catch {
            handle(error, message: "Failed to delete tracker")
        }
    }
    
    func isCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { record in
            record.trackerId == id && Calendar.current.isDate(record.date, inSameDayAs: currentDate)
        }
    }
    
    func completedDays(id: UUID) -> Int {
        completedTrackers.filter { $0.trackerId == id }.count
    }

    func categoryTitle(for trackerID: UUID) -> String? {
        categories.first { category in
            category.trackers.contains { $0.id == trackerID }
        }?.title
    }
    
    func toggleCompletion(for tracker: Tracker) {
        let isCompleted = isCompletedToday(id: tracker.id)
        do {
            if isCompleted {
                try trackerRecordStore.removeRecord(trackerId: tracker.id, date: currentDate)
            } else {
                try trackerRecordStore.addRecord(trackerId: tracker.id, date: currentDate)
            }
        } catch {
            handle(error, message: "Failed to toggle completion")
        }
    }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        do {
            let categoryCoreData = try trackerCategoryStore.fetchOrCreateCategory(title: categoryTitle)
            try trackerStore.addTracker(tracker, to: categoryCoreData)
        } catch {
            handle(error, message: "Failed to add tracker")
        }
    }

    func updateTracker(_ tracker: Tracker, in categoryTitle: String) {
        do {
            try trackerStore.updateTracker(tracker, in: categoryTitle)
        } catch {
            handle(error, message: "Failed to update tracker")
        }
    }
    
    // MARK: - Private Methods
    
    private func reloadData() {
        let weekday = currentWeekDay()
        do {
            try trackerStore.updatePredicate(searchText: searchText, weekday: weekday)
            categories = try trackerCategoryStore.fetchAllCategories()
            completedTrackers = try trackerRecordStore.fetchAllRecords()
            let filteredTrackers = try trackerStore.fetchTrackers()
            let filteredTrackerIDs = Set(filteredTrackers.map { $0.id })

            let filteredCategories: [TrackerCategory] = categories.compactMap { category in
                let trackers = category.trackers.filter { filteredTrackerIDs.contains($0.id) }
                if trackers.isEmpty { return nil }
                return TrackerCategory(title: category.title, trackers: trackers)
            }

            visibleCategories = buildVisibleCategories(from: filteredCategories)
        } catch {
            handle(error, message: "Failed to reload trackers")
            categories = []
            completedTrackers = []
            visibleCategories = []
        }
    }

    private func buildVisibleCategories(from filteredCategories: [TrackerCategory]) -> [TrackerCategory] {
        var pinnedTrackers: [Tracker] = []
        var otherCategories: [TrackerCategory] = []
        
        for category in filteredCategories {
            let pinned = category.trackers.filter { $0.isPinned }
            let others = category.trackers.filter { !$0.isPinned }
            
            pinnedTrackers.append(contentsOf: pinned)
            if !others.isEmpty {
                otherCategories.append(TrackerCategory(title: category.title, trackers: others))
            }
        }
        
        var result: [TrackerCategory] = []
        if !pinnedTrackers.isEmpty {
            result.append(TrackerCategory(title: "Закрепленные", trackers: pinnedTrackers))
        }
        result.append(contentsOf: otherCategories)
        return result
    }
    
    private func updateEmptyState() {
        let isEmpty = visibleCategories.isEmpty
        let isSearch = !(searchText?.isEmpty ?? true)
        onEmptyStateChange?(isEmpty, isSearch)
    }
    
    private func currentWeekDay() -> WeekDay {
        let component = Calendar.current.component(.weekday, from: currentDate)
        return WeekDay(rawValue: component) ?? .monday
    }
}

// MARK: - Store Delegates

extension TrackersViewModel: TrackerStoreDelegate, TrackerCategoryStoreDelegate, TrackerRecordStoreDelegate {
    func trackerStoreDidUpdate() {
        reloadData()
    }
    
    func trackerCategoryStoreDidUpdate() {
        reloadData()
    }
    
    func trackerRecordStoreDidUpdate() {
        do {
            completedTrackers = try trackerRecordStore.fetchAllRecords()
            onVisibleCategoriesChange?(visibleCategories)
        } catch {
            handle(error, message: "Failed to refresh records")
        }
    }
}

private extension TrackersViewModel {
    func handle(_ error: Error, message: String) {
        AppLogger.coreData.error("\(message, privacy: .public): \(error.localizedDescription, privacy: .public)")
        onError?(error.localizedDescription)
    }
}
