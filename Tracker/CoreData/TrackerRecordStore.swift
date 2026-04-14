//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Анастасия Федотова on 14.04.2026.
//

import UIKit
import CoreData

// MARK: - TrackerRecordStoreDelegate

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidUpdate()
}

// MARK: - TrackerRecordStore

final class TrackerRecordStore: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
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
    
    func addRecord(trackerId: UUID, date: Date) throws {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        guard let trackerCoreData = try context.fetch(fetchRequest).first else { return }
        
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.date = Calendar.current.startOfDay(for: date)
        recordCoreData.tracker = trackerCoreData
        
        try context.save()
    }
    
    func removeRecord(trackerId: UUID, date: Date) throws {
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as CVarArg,
            endOfDay as CVarArg
        )
        
        let results = try context.fetch(fetchRequest)
        results.forEach { context.delete($0) }
        
        try context.save()
    }
    
    func fetchAllRecords() throws -> [TrackerRecord] {
        let objects = fetchedResultsController.fetchedObjects ?? []
        return objects.compactMap { recordCoreData in
            guard
                let date = recordCoreData.date,
                let trackerId = recordCoreData.tracker?.id
            else { return nil }
            
            return TrackerRecord(trackerId: trackerId, date: date)
        }
    }
    
    func countRecords(for trackerId: UUID) throws -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        return try context.count(for: request)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.trackerRecordStoreDidUpdate()
    }
}
