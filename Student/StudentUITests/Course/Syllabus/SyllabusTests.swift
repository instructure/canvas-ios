//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
@testable import Core
import TestsFoundation

class SyllabusTests: StudentTest {
    let page = SyllabusPage.self
    let html = "<html>hello world</html>"
    lazy var course: APICourse = {
        let course = APICourse.make(["syllabus_body": html, "course_code": "abc"])
        mockData(GetCourseRequest(courseID: course.id, include: [.syllabusBody]), value: course)
        return course
    }()

    func mockAssignment(_ assignment: APIAssignment) -> APIAssignment {
        mockData(GetAssignmentRequest(courseID: course.id, assignmentID: assignment.id.value, include: [.submission]), value: assignment)
        return assignment
    }

    func testLoad() {
        mockData(GetCustomColorsRequest(), value: APICustomColors(custom_colors: [
            course.canvasContextID: "#123456",
            ]))

        _ = mockAssignment(APIAssignment.make([
            "name": "Discuss this",
            "description": "Say it like you mean it",
            "points_possible": 15.1,
            "due_at": DateComponents(calendar: Calendar.current, year: 2035, month: 1, day: 1, hour: 8).date,
            "submission_types": [ "discussion_topic" ],
            ]))

        show("/courses/\(course.id)/assignments/syllabus")

        page.waitToExist(.menu, timeout: 5)
        NavBar.assertText(.title, equals: "Course Syllabus")
        NavBar.assertText(.subtitle, equals: course.course_code!)

        page.waitToExist(.syllabusWebView, timeout: 5)
        let description = app?.webViews.staticTexts.firstMatch.label
        XCTAssertEqual(description, "hello world")
    }
}
