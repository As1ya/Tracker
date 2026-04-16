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
        return controller
    }()
    
    // MARK: - Init
    
    convenience override init() {
        let context = CoreDataStack.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.trackerStore = TrackerStore(context: context)
        super.init()
    }
    
    // MARK: - Public Methods
    
    func createCategory(title: String) throws -> TrackerCategoryCoreData {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTitle.isEmpty else {
            throw StoreError.emptyTitle
        }

        if try fetchCategoryCoreData(title: normalizedTitle) != nil {
            throw StoreError.categoryAlreadyExists
        }

        let category = TrackerCategoryCoreData(context: context)
        category.title = normalizedTitle
        try context.save()
        return category
    }
    
    func fetchAllCategories() throws -> [TrackerCategory] {
        try fetchedResultsController.performFetch()
        let objects = fetchedResultsController.fetchedObjects ?? []
        return try objects.map { try trackerCategory(from: $0) }
    }
    
    func fetchCategoryCoreData(title: String) throws -> TrackerCategoryCoreData? {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", normalizedTitle)
        return try context.fetch(request).first
    }
    
    func fetchOrCreateCategory(title: String) throws -> TrackerCategoryCoreData {
        if let existing = try fetchCategoryCoreData(title: title) {
            return existing
        }
        return try createCategory(title: title)
    }

    func updateCategory(oldTitle: String, newTitle: String) throws {
        let normalizedNewTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedNewTitle.isEmpty else {
            throw StoreError.emptyTitle
        }

        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", oldTitle)
        
        if let category = try context.fetch(request).first {
            let duplicate = try fetchCategoryCoreData(title: normalizedNewTitle)
            if let duplicate, duplicate.objectID != category.objectID {
                throw StoreError.categoryAlreadyExists
            }

            category.title = normalizedNewTitle
            try context.save()
        }
    }

    func deleteCategoryByTitle(_ title: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        
        if let category = try context.fetch(request).first {
            context.delete(category)
            try context.save()
        }
    }

    func deleteCategory(_ category: TrackerCategoryCoreData) throws {
        context.delete(category)
        try context.save()
    }
    
    // MARK: - Private Methods
    
    private func trackerCategory(from coreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        let title = coreData.title ?? ""
        let trackerObjects = coreData.trackers?.allObjects as? [TrackerCoreData] ?? []
        let trackers = try trackerObjects
            .map { try trackerStore.tracker(from: $0) }
            .sorted { $0.name < $1.name }
        
        return TrackerCategory(title: title, trackers: trackers)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.trackerCategoryStoreDidUpdate()
    }
}
