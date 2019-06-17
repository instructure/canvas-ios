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
import XCTest

class SyllabusTests: StudentUITestCase {
    let html = "hello world"
    lazy var course: APICourse = {
        let course = APICourse.make(course_code: "abc", syllabus_body: html)
        mockData(GetCourseRequest(courseID: course.id), value: course)
        return course
    }()

    func mockAssignments(_ assignments: [APIAssignment]) -> [APIAssignment] {
        mockData(GetAssignmentsRequest(courseID: course.id), value: assignments)
        return assignments
    }

    func testSyllabusLoad() {
        let assignmentName = "Foobar"
        mockData(GetCustomColorsRequest(), value: APICustomColors(custom_colors: [
            course.canvasContextID: "#123456",
            ]))

        _ = mockAssignments([APIAssignment.make(name: assignmentName, description: "hello world", submission: APISubmission.make())])

        show("/courses/\(course.id)/assignments/syllabus")

        Syllabus.menu.waitToExist()
        XCTAssertEqual(NavBar.title.label, "Course Syllabus")
        XCTAssertEqual(NavBar.subtitle.label, course.course_code)

        app.find(label: "hello world").waitToExist()

        app.swipeLeft()

        let cells = app.cells.containing(NSPredicate(format: "label CONTAINS %@", assignmentName))

        let assignmentCell = cells.firstMatch
        assignmentCell.tap()
        AssignmentDetails.name.waitToExist(5)

        XCTAssertEqual(navBarColorHex(), "#123456")
    }
}
