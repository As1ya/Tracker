//
//  Resources.swift
//  Tracker
//
//  Created by Анастасия Федотова on 15.04.2026.
//

import Foundation

enum Resources {
    enum Images {
        static let trackersTab = "record.circle.fill"
        static let statisticsTab = "hare.fill"
        static let onboarding1 = "BackGround1"
        static let onboarding2 = "BackGround2"
        static let emptyTrackers = "star"
        static let plus = "plus"
        static let searchPrefix = "magnifyingglass"
    }
    
    enum Constants {
        static let defaultPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let mediumPadding: CGFloat = 12
        static let largePadding: CGFloat = 20
        static let extraLargePadding: CGFloat = 24
        
        static let buttonHeight: CGFloat = 60
        static let cellHeight: CGFloat = 75
        static let iconSize: CGFloat = 80
        static let cornerRadius: CGFloat = 16
    }
    
    enum UserDefaultsKeys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }
}
