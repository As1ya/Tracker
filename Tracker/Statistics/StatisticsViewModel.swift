//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Анастасия Федотова on 19.04.2026.
//

import Foundation
import OSLog

// MARK: - StatisticsViewModel

final class StatisticsViewModel {
    
    // MARK: - Nested Types
    
    struct StatisticItem {
        let value: Int
        let title: String
    }
    
    // MARK: - Dependencies
    
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    
    // MARK: - Private Properties
    
    private let calendar = Calendar.current
    
    // MARK: - Public Callbacks
    
    var onStatisticsChange: (([StatisticItem]) -> Void)?
    var onEmptyStateChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Initialization

    init(
        trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore(),
        trackerRecordStore: TrackerRecordStore = TrackerRecordStore()
    ) {
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
    }
    
    // MARK: - Public Methods

    func reload() {
        do {
            let categories = try trackerCategoryStore.fetchAllCategories()
            let records = try trackerRecordStore.fetchAllRecords()
            let items = buildStatistics(categories: categories, records: records)
            let isEmpty = items.allSatisfy { $0.value == 0 }

            onStatisticsChange?(items)
            onEmptyStateChange?(isEmpty)
        } catch {
            AppLogger.coreData.error("Failed to load statistics: \(error.localizedDescription, privacy: .public)")
            onError?(error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods - Statistics Building

    private func buildStatistics(categories: [TrackerCategory], records: [TrackerRecord]) -> [StatisticItem] {
        let habits = categories.flatMap(\.trackers).filter(\.isHabit)
        let habitIDs = Set(habits.map(\.id))
        let habitRecords = records.filter { habitIDs.contains($0.trackerId) }

        return [
            StatisticItem(
                value: bestPeriod(for: habits, records: habitRecords),
                title: NSLocalizedString("statistics.bestPeriod", comment: "")
            ),
            StatisticItem(
                value: idealDays(for: habits, records: habitRecords),
                title: NSLocalizedString("statistics.idealDays", comment: "")
            ),
            StatisticItem(
                value: habitRecords.count,
                title: NSLocalizedString("statistics.completedTrackers", comment: "")
            ),
            StatisticItem(
                value: averageValue(for: habitRecords),
                title: NSLocalizedString("statistics.averageValue", comment: "")
            )
        ]
    }
    
    // MARK: - Private Methods - Calculations

    private func bestPeriod(for habits: [Tracker], records: [TrackerRecord]) -> Int {
        let recordsByTracker = Dictionary(grouping: records, by: \.trackerId).mapValues { trackerRecords in
            Set(trackerRecords.map { calendar.startOfDay(for: $0.date) })
        }

        return habits.reduce(0) { currentBest, tracker in
            guard let completedDates = recordsByTracker[tracker.id], !completedDates.isEmpty else {
                return currentBest
            }

            return max(currentBest, bestPeriod(for: tracker, completedDates: completedDates))
        }
    }

    private func bestPeriod(for tracker: Tracker, completedDates: Set<Date>) -> Int {
        let sortedDates = completedDates.sorted()
        guard
            let firstDate = sortedDates.first,
            let lastDate = sortedDates.last
        else {
            return 0
        }

        var maxStreak = 0
        var currentStreak = 0
        var currentDate = firstDate

        while currentDate <= lastDate {
            if isTrackerScheduled(tracker, on: currentDate) {
                if completedDates.contains(currentDate) {
                    currentStreak += 1
                    maxStreak = max(maxStreak, currentStreak)
                } else {
                    currentStreak = 0
                }
            }

            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return maxStreak
    }

    private func idealDays(for habits: [Tracker], records: [TrackerRecord]) -> Int {
        guard !records.isEmpty else { return 0 }

        let normalizedDates = records.map { calendar.startOfDay(for: $0.date) }
        guard
            let startDate = normalizedDates.min(),
            let endDate = normalizedDates.max()
        else {
            return 0
        }

        let recordsByDate = Dictionary(grouping: records, by: { calendar.startOfDay(for: $0.date) })
            .mapValues { Set($0.map(\.trackerId)) }

        var idealDaysCount = 0
        var currentDate = startDate

        while currentDate <= endDate {
            let scheduledHabits = habits.filter { isTrackerScheduled($0, on: currentDate) }
            let scheduledIDs = Set(scheduledHabits.map(\.id))

            if !scheduledIDs.isEmpty,
               let completedIDs = recordsByDate[currentDate],
               scheduledIDs.isSubset(of: completedIDs) {
                idealDaysCount += 1
            }

            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return idealDaysCount
    }

    private func averageValue(for records: [TrackerRecord]) -> Int {
        guard !records.isEmpty else { return 0 }

        let distinctDays = Set(records.map { calendar.startOfDay(for: $0.date) }).count
        guard distinctDays > 0 else { return 0 }

        let average = Double(records.count) / Double(distinctDays)
        return Int(round(average))
    }
    
    // MARK: - Private Methods - Helpers

    private func isTrackerScheduled(_ tracker: Tracker, on date: Date) -> Bool {
        guard let weekday = WeekDay(rawValue: calendar.component(.weekday, from: date)) else {
            return false
        }

        return tracker.schedule.contains(weekday)
    }
}
