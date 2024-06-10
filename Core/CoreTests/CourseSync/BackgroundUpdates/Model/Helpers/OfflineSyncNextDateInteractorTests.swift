//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import XCTest

class OfflineSyncNextDateInteractorTests: XCTestCase {
    private var defaults1 = SessionDefaults(sessionID: "test1")
    private var defaults2 = SessionDefaults(sessionID: "test2")

    override func tearDown() {
        defaults1.reset()
        defaults2.reset()
        super.tearDown()
    }

    func testPicksClosestDate() {
        let date1 = Date().addingTimeInterval(60)
        let date2 = Date()
        var defaults = SessionDefaults(sessionID: "test1")
        defaults.offlineSyncNextDate = date1
        defaults.isOfflineAutoSyncEnabled = true
        defaults = SessionDefaults(sessionID: "test2")
        defaults.offlineSyncSelections = ["a1"]
        defaults.offlineSyncNextDate = date2
        defaults.isOfflineAutoSyncEnabled = true

        // WHEN
        let result = OfflineSyncNextDateInteractor().calculate(sessionUniqueIDs: ["test1", "test2"])

        // THEN
        XCTAssertEqual(result, date2)
    }

    func testSyncSkippingWithoutCourses() {
        let date1 = Date()
        var defaults = SessionDefaults(sessionID: "test1")
        defaults = SessionDefaults(sessionID: "test")
        defaults.offlineSyncNextDate = date1
        defaults.isOfflineAutoSyncEnabled = true

        // WHEN
        let result = OfflineSyncNextDateInteractor().calculate(sessionUniqueIDs: ["test1", "test2"])

        // THEN
        XCTAssertEqual(result, nil)
    }

    func testPicksNoDateIfAutoSyncIsDisabled() {
        let date = Date()
        var defaults = SessionDefaults(sessionID: "test1")
        defaults.offlineSyncNextDate = date
        defaults.isOfflineAutoSyncEnabled = false

        // WHEN
        let result = OfflineSyncNextDateInteractor().calculate(sessionUniqueIDs: ["test1", "test2"])

        // THEN
        XCTAssertNil(result)
    }
}
