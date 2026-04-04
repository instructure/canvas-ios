//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

@testable import Core
@testable import Horizon
import XCTest

final class HSyncNextDateInteractorTests: XCTestCase {

    private static let testData = (
        sessionID1: "h-session-1",
        sessionID2: "h-session-2"
    )
    private lazy var testData = Self.testData

    override func tearDown() {
        var defaults = SessionDefaults(sessionID: testData.sessionID1)
        defaults.reset()
        defaults = SessionDefaults(sessionID: testData.sessionID2)
        defaults.reset()
        super.tearDown()
    }

    // MARK: - Edge cases

    func test_calculate_withEmptySessionList_shouldReturnNil() {
        let result = HSyncNextDateInteractor().calculate(sessionUniqueIDs: [])

        XCTAssertEqual(result, nil)
    }

    // MARK: - Filtering

    func test_calculate_whenAutoSyncIsDisabled_shouldReturnNil() {
        var defaults = SessionDefaults(sessionID: testData.sessionID1)
        defaults.isHorizonAutoSyncEnabled = false
        defaults.horizonOfflineSyncItems = ["course-1"]
        defaults.horizonSyncNextDate = Date()

        let result = HSyncNextDateInteractor().calculate(sessionUniqueIDs: [testData.sessionID1])

        XCTAssertEqual(result, nil)
    }

    func test_calculate_whenSyncItemsIsEmpty_shouldReturnNil() {
        var defaults = SessionDefaults(sessionID: testData.sessionID1)
        defaults.isHorizonAutoSyncEnabled = true
        defaults.horizonOfflineSyncItems = []
        defaults.horizonSyncNextDate = Date()

        let result = HSyncNextDateInteractor().calculate(sessionUniqueIDs: [testData.sessionID1])

        XCTAssertEqual(result, nil)
    }

    func test_calculate_whenSyncDateNotSet_shouldReturnNil() {
        var defaults = SessionDefaults(sessionID: testData.sessionID1)
        defaults.isHorizonAutoSyncEnabled = true
        defaults.horizonOfflineSyncItems = ["course-1"]
        defaults.horizonSyncNextDate = nil

        let result = HSyncNextDateInteractor().calculate(sessionUniqueIDs: [testData.sessionID1])

        XCTAssertEqual(result, nil)
    }

    // MARK: - Date selection

    func test_calculate_withMultipleSessions_shouldReturnEarliestDate() {
        let earlierDate = Date(timeIntervalSince1970: 1_000_000)
        let laterDate = Date(timeIntervalSince1970: 2_000_000)

        var defaults = SessionDefaults(sessionID: testData.sessionID1)
        defaults.isHorizonAutoSyncEnabled = true
        defaults.horizonOfflineSyncItems = ["course-1"]
        defaults.horizonSyncNextDate = laterDate

        defaults = SessionDefaults(sessionID: testData.sessionID2)
        defaults.isHorizonAutoSyncEnabled = true
        defaults.horizonOfflineSyncItems = ["course-2"]
        defaults.horizonSyncNextDate = earlierDate

        let result = HSyncNextDateInteractor().calculate(sessionUniqueIDs: [testData.sessionID1, testData.sessionID2])

        XCTAssertEqual(result, earlierDate)
    }
}
