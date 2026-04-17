//
//  UserDefaultsService.swift
//  Tracker
//
//  Created by Анастасия Федотова on 17.04.2026.
//

import Foundation

final class UserDefaultsService {
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard

    private init() {}

    private enum Key {
        static let hasSeenOnboarding = Resources.UserDefaultsKeys.hasSeenOnboarding
    }

    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasSeenOnboarding) }
        set { defaults.set(newValue, forKey: Key.hasSeenOnboarding) }
    }
}
