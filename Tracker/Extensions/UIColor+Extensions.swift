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
    static let trSelection1 = UIColor(named: "ColorSelection1") ?? .systemRed
    static let trSelection2 = UIColor(named: "ColorSelection2") ?? .systemOrange
    static let trSelection3 = UIColor(named: "ColorSelection3") ?? .systemBlue
    static let trSelection4 = UIColor(named: "ColorSelection4") ?? .systemPurple
    static let trSelection5 = UIColor(named: "ColorSelection5") ?? .systemGreen
    static let trSelection6 = UIColor(named: "ColorSelection6") ?? .systemPink
    static let trSelection7 = UIColor(named: "ColorSelection7") ?? .systemPink
    static let trSelection8 = UIColor(named: "ColorSelection8") ?? .systemBlue
    static let trSelection9 = UIColor(named: "ColorSelection9") ?? .systemGreen
    static let trSelection10 = UIColor(named: "ColorSelection10") ?? .systemPurple
    static let trSelection11 = UIColor(named: "ColorSelection11") ?? .systemOrange
    static let trSelection12 = UIColor(named: "ColorSelection12") ?? .systemPink
    static let trSelection13 = UIColor(named: "ColorSelection13") ?? .systemOrange
    static let trSelection14 = UIColor(named: "ColorSelection14") ?? .systemBlue
    static let trSelection15 = UIColor(named: "ColorSelection15") ?? .systemPurple
    static let trSelection16 = UIColor(named: "ColorSelection16") ?? .systemPurple
    static let trSelection17 = UIColor(named: "ColorSelection17") ?? .systemPurple
    static let trSelection18 = UIColor(named: "ColorSelection18") ?? .systemGreen
    
    static let trSelections: [UIColor] = [
        trSelection1, trSelection2, trSelection3, trSelection4,
        trSelection5, trSelection6, trSelection7, trSelection8,
        trSelection9, trSelection10, trSelection11, trSelection12,
        trSelection13, trSelection14, trSelection15, trSelection16,
        trSelection17, trSelection18
    ]
}
