//
//  Tracker.swift
//  Tracker
//
//  Created by Анастасия Федотова on 09.04.2026.
//

import UIKit


struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
}
