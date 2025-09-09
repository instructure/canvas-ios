//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Foundation
import XCTest
@testable import Core

class UserProfileTests: CoreTestCase {
    func testUserProfile() {
        let apiProfile = APIProfile.make(k5_user: true, time_zone: "America/Los_Angeles")
        let profile = UserProfile.save(apiProfile, in: databaseClient)
        XCTAssertEqual(profile.id, apiProfile.id.value)
        XCTAssertEqual(profile.calendarURL, apiProfile.calendar?.ics)
        XCTAssertEqual(profile.isK5User, true)
        XCTAssertEqual(profile.defaultTimeZone, apiProfile.time_zone)
    }

    func testGetUserProfile() {
        let useCase = GetUserProfile()
        XCTAssertEqual(useCase.userID, "self")
        XCTAssertEqual(useCase.cacheKey, "get-user-self-profile")
        XCTAssertEqual(useCase.request.userID, "self")
    }

    func testK5UserDefaultValue() {
        let apiProfile = APIProfile.make(k5_user: nil)
        let profile = UserProfile.save(apiProfile, in: databaseClient)
        XCTAssertEqual(profile.isK5User, false)
    }

    func testCalendarURLPreservedWhenAPIResponseMissingCalendar() {
        // First, save a profile with a calendar URL
        let originalCalendarURL = URL(string: "https://example.com/calendar.ics")!
        let apiProfileWithCalendar = APIProfile.make(
            calendar: .init(ics: originalCalendarURL)
        )
        let profile = UserProfile.save(apiProfileWithCalendar, in: databaseClient)
        XCTAssertEqual(profile.calendarURL, originalCalendarURL)

        // Then save the same profile again, but this time without calendar data
        let apiProfileWithoutCalendar = APIProfile.make(
            id: apiProfileWithCalendar.id,
            calendar: nil
        )
        let updatedProfile = UserProfile.save(apiProfileWithoutCalendar, in: databaseClient)

        // Verify the calendar URL is preserved
        XCTAssertEqual(updatedProfile.calendarURL, originalCalendarURL)
        XCTAssertEqual(profile.id, updatedProfile.id) // Same profile object
    }
}
