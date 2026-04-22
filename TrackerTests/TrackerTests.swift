//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Анастасия Федотова on 09.04.2026.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {

    func test_emptyState_rendersCorrectly() {
           let vc = TrackersViewController()
           assertSnapshot(of: vc, as: .image(on: .iPhone13))
       }
}
