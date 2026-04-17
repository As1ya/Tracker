//
//  TrackerStore.swift
//  Tracker
//
//  Created by Анастасия Федотова on 14.04.2026.
//

import UIKit
import CoreData

// MARK: - TrackerStoreDelegate

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate()
}

// MARK: - TrackerStore

final class TrackerStore: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()
    
    // MARK: - Init
    
    convenience override init() {
        let context = CoreDataStack.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // MARK: - Public Methods
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.isPinned = tracker.isPinned
        trackerCoreData.colorHex = UIColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = tracker.schedule.map { String($0.rawValue) }.joined(separator: ",")
        trackerCoreData.category = category
        
        try context.save()
    }

    func updateTracker(_ tracker: Tracker, in categoryTitle: String) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        guard let trackerCoreData = try context.fetch(request).first else { return }
        
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = UIColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = tracker.schedule.map { String($0.rawValue) }.joined(separator: ",")
        trackerCoreData.isPinned = tracker.isPinned
        
        let categoryRequest = TrackerCategoryCoreData.fetchRequest()
        categoryRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
        if let category = try context.fetch(categoryRequest).first {
            trackerCoreData.category = category
        }
        
        try context.save()
    }

    func togglePin(for tracker: Tracker) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        if let trackerCoreData = try context.fetch(request).first {
            trackerCoreData.isPinned.toggle()
            try context.save()
        }
    }
    func updatePredicate(searchText: String?, weekday: WeekDay) throws {
        var predicates: [NSPredicate] = []
        
        // Filter by weekday
        let weekdayPredicate = NSPredicate(format: "schedule CONTAINS %@", String(weekday.rawValue))
        predicates.append(weekdayPredicate)
        
        // Filter by search text
        if let searchText = searchText, !searchText.isEmpty {
            let searchPredicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
            predicates.append(searchPredicate)
        }
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        try fetchedResultsController.performFetch()
    }
    
    func fetchTrackers() throws -> [Tracker] {
        try fetchedResultsController.performFetch()
        let objects = fetchedResultsController.fetchedObjects ?? []
        return try objects.map { try tracker(from: $0) }
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        if let trackerCoreData = try context.fetch(request).first {
            context.delete(trackerCoreData)
            try context.save()
        }
    }
    
    // MARK: - Conversion
    
    func tracker(from coreData: TrackerCoreData) throws -> Tracker {
        guard
            let id = coreData.id,
            let name = coreData.name,
            let emoji = coreData.emoji,
            let colorHex = coreData.colorHex
        else {
            throw StoreError.decodingError
        }
        
        let color = UIColorMarshalling.color(from: colorHex)
        let schedule = parseSchedule(coreData.schedule)
        let isPinned = coreData.isPinned
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule, isPinned: isPinned)
    }
    
    // MARK: - Private Methods
    
    private func parseSchedule(_ scheduleString: String?) -> [WeekDay] {
        guard let scheduleString = scheduleString, !scheduleString.isEmpty else { return [] }
        return scheduleString
            .split(separator: ",")
            .compactMap { Int(String($0)) }
            .compactMap { WeekDay(rawValue: $0) }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.trackerStoreDidUpdate()
    }
}

// MARK: - StoreError

enum StoreError: Error {
    case decodingError
    case duplicateRecord
    case categoryAlreadyExists
    case emptyTitle
}

extension StoreError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .decodingError:
            return "Не удалось прочитать сохранённые данные."
        case .duplicateRecord:
            return "Запись за этот день уже существует."
        case .categoryAlreadyExists:
            return "Категория с таким названием уже существует."
        case .emptyTitle:
            return "Название не может быть пустым."
        }
    }
}
