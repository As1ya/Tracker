//
//  WeekDay.swift
//  Tracker
//
//  Created by Анастасия Федотова on 13.04.2026.
//

import Foundation

enum WeekDay: Int, CaseIterable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    var title: String {
        switch self {
        case .monday: L10n.Weekday.Monday.full
        case .tuesday: L10n.Weekday.Tuesday.full
        case .wednesday: L10n.Weekday.Wednesday.full
        case .thursday: L10n.Weekday.Thursday.full
        case .friday: L10n.Weekday.Friday.full
        case .saturday: L10n.Weekday.Saturday.full
        case .sunday: L10n.Weekday.Sunday.full
        }
    }
    
    var shortTitle: String {
        switch self {
        case .monday: L10n.Weekday.Monday.short
        case .tuesday: L10n.Weekday.Tuesday.short
        case .wednesday: L10n.Weekday.Wednesday.short
        case .thursday: L10n.Weekday.Thursday.short
        case .friday: L10n.Weekday.Friday.short
        case .saturday: L10n.Weekday.Saturday.short
        case .sunday: L10n.Weekday.Sunday.short
        }
    }
}
