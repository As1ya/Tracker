//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Анастасия Федотова on 15.04.2026.
//

import Foundation
import OSLog

final class CategoryViewModel {

    struct CategoryCellViewModel {
        let title: String
        let isSelected: Bool
        let isFirst: Bool
        let isLast: Bool
    }
    
    // MARK: - Properties
    private let categoryStore: TrackerCategoryStore
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesChange?(categories)
        }
    }
    
    var onCategoriesChange: (([TrackerCategory]) -> Void)?
    var onRowsChange: (([CategoryCellViewModel]) -> Void)?
    var onError: ((String) -> Void)?
    
    private(set) var selectedCategoryTitle: String?
    private(set) var rowViewModels: [CategoryCellViewModel] = [] {
        didSet {
            onRowsChange?(rowViewModels)
        }
    }
    
    // MARK: - Init
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore(), selectedCategory: String?) {
        self.categoryStore = categoryStore
        self.selectedCategoryTitle = selectedCategory
        self.categoryStore.delegate = self
        fetchCategories()
    }
    
    // MARK: - Public Methods
    func fetchCategories() {
        do {
            categories = try categoryStore.fetchAllCategories()
            rebuildRows()
        } catch {
            AppLogger.coreData.error("Failed to fetch categories: \(error.localizedDescription, privacy: .public)")
            categories = []
            rebuildRows()
            onError?(error.localizedDescription)
        }
    }
    
    func selectCategory(at index: Int) {
        guard rowViewModels.indices.contains(index) else { return }
        selectCategory(title: rowViewModels[index].title)
    }

    func selectCategory(title: String) {
        selectedCategoryTitle = title
        rebuildRows()
    }
    
    func addCategory(title: String) {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            _ = try categoryStore.createCategory(title: normalizedTitle)
        } catch {
            AppLogger.coreData.error("Failed to add category: \(error.localizedDescription, privacy: .public)")
            onError?(error.localizedDescription)
        }
    }

    func editCategory(oldTitle: String, newTitle: String) {
        do {
            try categoryStore.updateCategory(oldTitle: oldTitle, newTitle: newTitle)
        } catch {
            AppLogger.coreData.error("Failed to edit category: \(error.localizedDescription, privacy: .public)")
            onError?(error.localizedDescription)
        }
    }

    func deleteCategory(at index: Int) {
        guard rowViewModels.indices.contains(index) else { return }
        deleteCategory(title: rowViewModels[index].title)
    }

    func deleteCategory(title: String) {
        do {
            try categoryStore.deleteCategoryByTitle(title)
        } catch {
            AppLogger.coreData.error("Failed to delete category: \(error.localizedDescription, privacy: .public)")
            onError?(error.localizedDescription)
        }
    }

    func row(at index: Int) -> CategoryCellViewModel? {
        guard rowViewModels.indices.contains(index) else { return nil }
        return rowViewModels[index]
    }

    private func rebuildRows() {
        rowViewModels = categories.enumerated().map { index, category in
            CategoryCellViewModel(
                title: category.title,
                isSelected: category.title == selectedCategoryTitle,
                isFirst: index == 0,
                isLast: index == categories.count - 1
            )
        }
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidUpdate() {
        fetchCategories()
    }
}
