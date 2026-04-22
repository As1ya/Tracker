//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Анастасия Федотова on 15.04.2026.
//

import Foundation
import CoreData
import OSLog

// MARK: - CoreDataStack

final class CoreDataStack {
    
    // MARK: - Singleton
    
    static let shared = CoreDataStack()
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        var loadError: NSError?

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                loadError = error
                AppLogger.coreData.critical("Failed to load persistent stores: \(error.localizedDescription, privacy: .public)")
            }
        }

        if let loadError {
            fatalError("Failed to load Core Data store: \(loadError), \(loadError.userInfo)")
        }

        return container
    }()
    
    // MARK: - Context
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Saving
    
    func saveContext() throws {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            AppLogger.coreData.error("Failed to save context: \(nsError.localizedDescription, privacy: .public)")
            throw CoreDataStackError.saveFailed(underlying: nsError)
        }
    }
}

// MARK: - CoreDataStackError

enum CoreDataStackError: LocalizedError {
    case saveFailed(underlying: NSError)

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            L10n.CoreData.saveFailed
        }
    }
}
