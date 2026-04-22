//
//  TrackerFilter.swift
//  Tracker
//
//  Created by Анастасия Федотова on 19.04.2026.
//

import Foundation

enum TrackerFilter: Int, CaseIterable {
    case all
    case today
    case completed
    case notCompleted
    
    var title: String {
        switch self {
        case .all: return L10n.Filters.all
        case .today: return L10n.Filters.today
        case .completed: return L10n.Filters.completed
        case .notCompleted: return L10n.Filters.notCompleted
        }
    }
}
