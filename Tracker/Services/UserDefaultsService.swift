//
//  UserDefaultsService.swift
//  Tracker
//
//  Created by Анастасия Федотова on 17.04.2026.
//

import Foundation

// MARK: - UserDefaultsService

final class UserDefaultsService {
    
    // MARK: - Singleton
    
    static let shared = UserDefaultsService()
    
    // MARK: - Private Properties
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Private Constants
    
    private enum Key {
        static let hasSeenOnboarding = Resources.UserDefaultsKeys.hasSeenOnboarding
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Properties
    
    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasSeenOnboarding) }
        set { defaults.set(newValue, forKey: Key.hasSeenOnboarding) }
    }
}
