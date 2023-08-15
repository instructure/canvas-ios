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

class CourseSyncSyllabusInteractorLiveTests: CoreTestCase {

    func testSuccessfulFetch() {
        mockSyllabusContent()
        mockSyllabusSummary()

        let testee = CourseSyncSyllabusInteractorLive()

        XCTAssertFinish(testee.getContent(courseId: "testCourse"))
        let courses: [Course] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(courses.count, 1)
        XCTAssertEqual(courses.first?.syllabusBody, "testSyllabus")
        let events: [CalendarEvent] = databaseClient.fetch(scope: .all(orderBy: "id"))
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events.first?.id, "1")
        XCTAssertEqual(events.last?.id, "2")
    }

    private func mockSyllabusContent() {
        api.mock(GetCustomColors(),
                 value: .init(custom_colors: [:]))
        api.mock(GetCourse(courseID: "testCourse"),
                 value: .make(id: "testCourse",
                              syllabus_body: "testSyllabus"))
    }

    private func mockSyllabusSummary() {
        api.mock(GetCourseSettings(courseID: "testCourse"),
                 value: .init(usage_rights_required: false,
                              syllabus_course_summary: true,
                              restrict_quantitative_data: false))
        api.mock(GetCalendarEvents(context: .course("testCourse"),
                                   type: .assignment),
                 value: [.make(id: "1")])
        api.mock(GetCalendarEvents(context: .course("testCourse"),
                                   type: .event),
                 value: [.make(id: "2")])
    }
}
