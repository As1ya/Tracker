//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Анастасия Федотова on 09.04.2026.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testMainScreen() {
           let vc = TrackersViewController()
           assertSnapshot(of: vc, as: .image(on: .iPhone13))
       }
}
