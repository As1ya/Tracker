//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Анастасия Федотова on 14.04.2026.
//

import UIKit
import CoreData

// MARK: - TrackerCategoryStoreDelegate

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidUpdate()
}

// MARK: - TrackerCategoryStore

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
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
        self.trackerStore = TrackerStore(context: context)
        super.init()
    }
    
    // MARK: - Public Methods
    
    func createCategory(title: String) throws -> TrackerCategoryCoreData {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        try context.save()
        return category
    }
    
    func fetchAllCategories() throws -> [TrackerCategory] {
        let objects = fetchedResultsController.fetchedObjects ?? []
        return objects.compactMap { try? trackerCategory(from: $0) }
    }
    
    func fetchCategoryCoreData(title: String) throws -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        return try context.fetch(request).first
    }
    
    func fetchOrCreateCategory(title: String) throws -> TrackerCategoryCoreData {
        if let existing = try fetchCategoryCoreData(title: title) {
            return existing
        }
        return try createCategory(title: title)
    }
    
    func deleteCategory(_ category: TrackerCategoryCoreData) throws {
        context.delete(category)
        try context.save()
    }
    
    // MARK: - Private Methods
    
    private func trackerCategory(from coreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = coreData.title else {
            throw StoreError.decodingError
        }
        
        let trackersCoreData = coreData.trackers as? Set<TrackerCoreData> ?? []
        let trackers = trackersCoreData.compactMap { try? trackerStore.tracker(from: $0) }
        
        return TrackerCategory(title: title, trackers: trackers)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.trackerCategoryStoreDidUpdate()
    }
}
