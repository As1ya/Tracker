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
    
    // MARK: - Singleton
    
    static let shared = AnalyticsService()

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
    
    func report(event: String, screen: String, item: String? = nil) {
        var params: [String: Any] = [
            Keys.event: event,
            Keys.screen: screen
        ]

        if let item = item {
            params[Keys.item] = item
        }

        AppMetrica.reportEvent(name: Keys.appMetricaEventName, parameters: params)

#if DEBUG
        print("LOG: [Analytics] Params: \(params)")
#endif
    }
}
