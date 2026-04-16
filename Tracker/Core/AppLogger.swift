//
//  AppLogger.swift
//  Tracker
//
//  Created by Анастасия Федотова on 16.04.2026.
//

import Foundation
import OSLog

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "Tracker"

    static let coreData = Logger(subsystem: subsystem, category: "CoreData")
    static let ui = Logger(subsystem: subsystem, category: "UI")
}
