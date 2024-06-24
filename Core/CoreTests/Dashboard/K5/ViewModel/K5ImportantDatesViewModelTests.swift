//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

class K5SImportantDatesViewModelTests: CoreTestCase {

    override func setUp() {
        super.setUp()

        Clock.mockNow(Date(fromISOString: "2022-01-03T10:00:00Z")!)

        let enrollments = [APIEnrollment.make(user_id: "1")]

        let apiCourses = [
            APICourse.make(id: "1", name: "Math", course_color: "#0000FF", enrollments: enrollments),
            APICourse.make(id: "2", name: "History", course_color: "#00FF00", enrollments: enrollments),
            APICourse.make(id: "3", name: "Music", course_color: "#FF0000", enrollments: enrollments),
        ]

        api.mock(GetUserCourses(userID: "1"), value: apiCourses)

        let contexts: [Context] = [
            Context(.course, id: "1"),
            Context(.course, id: "2"),
            Context(.course, id: "3"),
        ]

        let assignments = [
            APICalendarEvent.make(
                id: "0",
                html_url: URL(string: "https://canvas.instructure.com/assignments/12")!,
                title: "Important past assignment title",
                start_at: Date(fromISOString: "2022-01-02T08:00:00Z"),
                type: .assignment,
                context_code: "course_1",
                context_name: "Math"
            ),
            APICalendarEvent.make(
                id: "1",
                html_url: URL(string: "https://canvas.instructure.com/assignments/1")!,
                title: "Important assignment title",
                start_at: Date(fromISOString: "2022-01-03T08:00:00Z"),
                type: .assignment,
                context_code: "course_1",
                context_name: "Math"
            ),
        ]

        api.mock(GetCalendarEvents(contexts: contexts, type: .assignment, importantDates: true), value: assignments)

        let events = [
            APICalendarEvent.make(
                id: "2",
                html_url: URL(string: "https://canvas.instructure.com/events/2")!,
                title: "Important event title",
                start_at: Date(fromISOString: "2022-01-03T09:00:00Z"),
                type: .event,
                context_code: "course_2",
                context_name: "History"
            ),
            APICalendarEvent.make(
                id: "3",
                html_url: URL(string: "https://canvas.instructure.com/events/3")!,
                title: "This other important event title",
                start_at: Date(fromISOString: "2022-01-04T08:00:00Z"),
                type: .event,
                context_code: "course_3",
                context_name: "Music"
            ),
        ]

        api.mock(GetCalendarEvents(contexts: contexts, type: .event, importantDates: true), value: events)
    }

    override func tearDown() {
        Clock.reset()
        super.tearDown()
    }

    func testAddImportantDates() {
        let testee = K5ImportantDatesViewModel()
        XCTAssertEqual(testee.importantDates.count, 2)
        XCTAssertEqual(testee.importantDates.first?.title, "Monday, January 3")
        XCTAssertEqual(testee.importantDates.first?.events.count, 2)
        XCTAssertEqual(testee.importantDates[1].title, "Tuesday, January 4")
        XCTAssertEqual(testee.importantDates[1].events.count, 1)
    }
}
