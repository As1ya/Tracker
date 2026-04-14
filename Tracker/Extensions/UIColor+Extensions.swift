//
//  UIColor+Extensions.swift
//  Tracker
//
//  Created by Анастасия Федотова on 11.04.2026.
//

import UIKit

// MARK: - Tracker Colors
extension UIColor {
    
    // MARK: - Core Colors
    static let trBlack = UIColor(named: "TrackerBlack") ?? .black
    static let trWhite = UIColor(named: "TrackerWhite") ?? .white
    static let trGray = UIColor(named: "TrackerGray") ?? .systemGray
    static let trLightGray = UIColor(named: "TrackerLightGray") ?? .systemGray5
    static let trBackground = UIColor(named: "TrackerBackground") ?? .systemBackground
    static let trRed = UIColor(named: "TrackerRed") ?? .systemRed
    static let trBlue = UIColor(named: "TrackerBlue") ?? .systemBlue
    
    // MARK: - Selection Colors
    static let trSelections: [UIColor] = (1...18).map {
        UIColor(named: "ColorSelection\($0)") ?? .systemBlue
    }
}
