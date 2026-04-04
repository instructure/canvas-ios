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

final class HSyncScheduleInteractorTests: XCTestCase {

    private static let sessionID = "h-sync-schedule-session"

    override func tearDown() {
        var defaults = SessionDefaults(sessionID: Self.sessionID)
        defaults.reset()
        Clock.reset()
        super.tearDown()
    }

    // MARK: - updateNextSyncDate

    func test_updateNextSyncDate_withDailyFrequency_shouldAdvanceDateByOneDay() {
        let now = Date()
        Clock.mockNow(now)
        var defaults = SessionDefaults(sessionID: Self.sessionID)
        defaults.horizonSyncFrequency = .daily

        HSyncScheduleInteractor().updateNextSyncDate(sessionUniqueID: Self.sessionID)

        XCTAssertEqual(defaults.horizonSyncNextDate, now.addingTimeInterval(24 * 60 * 60))
    }

    func test_updateNextSyncDate_withWeeklyFrequency_shouldAdvanceDateByOneWeek() {
        let now = Date()
        Clock.mockNow(now)
        var defaults = SessionDefaults(sessionID: Self.sessionID)
        defaults.horizonSyncFrequency = .weekly

        HSyncScheduleInteractor().updateNextSyncDate(sessionUniqueID: Self.sessionID)

        XCTAssertEqual(defaults.horizonSyncNextDate, now.addingTimeInterval(7 * 24 * 60 * 60))
    }

    func test_updateNextSyncDate_whenNoFrequencySet_shouldDefaultToDaily() {
        let now = Date()
        Clock.mockNow(now)
        var defaults = SessionDefaults(sessionID: Self.sessionID)
        defaults.horizonSyncFrequency = nil

        HSyncScheduleInteractor().updateNextSyncDate(sessionUniqueID: Self.sessionID)

        XCTAssertEqual(defaults.horizonSyncNextDate, now.addingTimeInterval(24 * 60 * 60))
    }
}
