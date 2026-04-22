//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Анастасия Федотова on 19.04.2026.
//

import Foundation
import AppMetricaCore

// MARK: - AnalyticsService

final class AnalyticsService {
    
    // MARK: - Nested Types
    
    enum Event: String {
        case open
        case close
        case click
    }
    
    enum Screen: String {
        case main = "Main"
    }
    
    enum Item: String {
        case addTrack = "add_track"
        case track
        case filter
        case edit
        case delete
    }

    // MARK: - Private Constants
    
    private enum Keys {
        static let appMetricaEventName = "tracker_action"
        static let event = "event"
        static let screen = "screen"
        static let item = "item"
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    static func report(event: Event, screen: Screen, item: Item? = nil) {
        var params: [String: Any] = [
            Keys.event: event.rawValue,
            Keys.screen: screen.rawValue
        ]

        if let item {
            params[Keys.item] = item.rawValue
        }

        AppMetrica.reportEvent(name: Keys.appMetricaEventName, parameters: params)

#if DEBUG
        print("LOG: [Analytics] Params: \(params)")
#endif
    }
}
