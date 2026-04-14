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
        
        try? controller.performFetch()
        return controller
    }()
    
    // MARK: - Init
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
        trackerCoreData.colorHex = UIColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = tracker.schedule.map { String($0.rawValue) }.joined(separator: ",")
        trackerCoreData.category = category
        
        try context.save()
    }
    
    func fetchTrackers() throws -> [Tracker] {
        let objects = fetchedResultsController.fetchedObjects ?? []
        return objects.compactMap { try? tracker(from: $0) }
    }
    
    func deleteTracker(_ tracker: TrackerCoreData) throws {
        context.delete(tracker)
        try context.save()
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
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
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
}
