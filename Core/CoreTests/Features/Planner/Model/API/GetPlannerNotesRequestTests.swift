//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import XCTest
@testable import Core

class GetPlannerNotesRequestTests: XCTestCase {

    func testQuery() {
        // Given
        var calendar = Calendar.current
        calendar.timeZone = .gmt

        let startDate = Date.make(calendar: calendar, year: 2024, month: 3, day: 2, hour: 14, minute: 30, second: 30)
        let endDate = Date.make(calendar: calendar, year: 2024, month: 11, day: 25, hour: 12, minute: 15, second: 23)

        // When
        let request = GetPlannerNotesRequest(
            contexts: [
                Context(.course, id: "1"),
                Context(.user, id: "3")
            ],
            startDate: startDate,
            endDate: endDate,
            calendar: calendar
        )

        // Then
        XCTAssertEqual(request.path, "planner_notes")
        XCTAssertEqual(request.queryItems, [
            URLQueryItem(name: "per_page", value: "100"),
            URLQueryItem(name: "start_date", value: "2024-03-02T14:30:30Z"),
            URLQueryItem(name: "end_date", value: "2024-11-25T12:15:23Z"),
            URLQueryItem(name: "context_codes[]", value: "course_1"),
            URLQueryItem(name: "context_codes[]", value: "user_3")
        ])
    }
}
