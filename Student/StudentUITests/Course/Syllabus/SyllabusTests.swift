//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
@testable import Core
import TestsFoundation

class SyllabusTests: StudentTest {
    let page = SyllabusPage.self
    let html = "<html>hello world</html>"
    lazy var course: APICourse = {
        let course = APICourse.make(["syllabus_body": html, "course_code": "abc"])
        mockData(GetCourseRequest(courseID: course.id), value: course)
        return course
    }()

    func mockAssignment(_ assignment: APIAssignment) -> APIAssignment {
        mockData(GetAssignmentRequest(courseID: course.id, assignmentID: assignment.id.value, include: []), value: assignment)
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
