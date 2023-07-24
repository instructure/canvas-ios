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

@testable import Core
import XCTest

class CourseDetailsViewModelTests: CoreTestCase {

    func testTabCells() {
        AppEnvironment.shared.app = .teacher
        api.mock(GetContextPermissions(context: .course("1"), permissions: [.useStudentView]),
                 value: .make(use_student_view: true))
        api.mock(GetCourse(courseID: "1"),
                 value: .make(default_view: .syllabus))
        api.mock(GetContextTabs(context: .course("1")),
                 value: [
                    .make(id: ID("context_external_tool_2"),
                          html_url: URL(string: "/2")!,
                          label: "attendance",
                          type: .external),
                 ])
        let toolsRequest = api.mock(GetCourseNavigationToolsRequest(courseContextsCodes: ["course_1"]),
                                    value: [
                                        .init(id: "2",
                                              context_name: "course_1",
                                              context_id: "course_1",
                                              course_navigation: nil,
                                              name: "attendance",
                                              url: URL(string: "rollcall.instructure.com")!),
                                    ])
        toolsRequest.suspend()

        let testee = CourseDetailsViewModel(context: .course("1"))
        testee.viewDidAppear()
        toolsRequest.resume()

        guard case .data(let cellViewModels) = testee.state else {
            return XCTFail("Unexpected state")
        }

        guard cellViewModels.count == 2 else {
            return XCTFail("Invalid cell count \(cellViewModels.count)")
        }

        XCTAssertEqual(cellViewModels[0].label, "attendance")
        XCTAssertEqual(cellViewModels[1].label, "Student View")
    }

    func testTeacherProperties() {
        api.mock(GetCourse(courseID: "1"), value: .make(default_view: .syllabus))
        api.mock(GetContextTabs(context: .course("1")), value: [.make()])
        api.mock(GetContextPermissions(context: .course("1"), permissions: [.useStudentView]), value: .make(use_student_view: true))
        api.mock(GetCustomColors(), value: APICustomColors(custom_colors: ["course_1": "#FF0000"]))
        api.mock(GetCourseNavigationToolsRequest(courseContextsCodes: ["course_1"]), value: [])

        AppEnvironment.shared.app = .teacher
        let testee = CourseDetailsViewModel(context: .course("1"))
        XCTAssertEqual(testee.state, .loading)
        testee.viewDidAppear()

        XCTAssertEqual(testee.courseColor.hexString, UIColor(hexString: "#FF0000")!.ensureContrast(against: .backgroundLightest).hexString)
        XCTAssertEqual(testee.homeLabel, nil)
        XCTAssertEqual(testee.homeSubLabel, nil)
        XCTAssertEqual(testee.homeRoute, URL(string: "/empty?contextColor=ed0000")!)

        XCTAssertFalse(testee.showHome)
        XCTAssertTrue(testee.showSettings)
        XCTAssertTrue(testee.showStudentView)
        XCTAssertEqual(testee.courseName, "Course One")
        XCTAssertEqual(testee.navigationBarTitle, "C1")
        XCTAssertEqual(testee.settingsRoute, URL(string: "courses/1/settings")!)
        XCTAssertEqual(testee.courseID, "1")
    }

    func testStudentProperties() {
        api.mock(GetCourse(courseID: "1"), value: .make(default_view: .syllabus))
        api.mock(GetContextTabs(context: .course("1")), value: [.make()])
        api.mock(GetContextPermissions(context: .course("1"), permissions: [.useStudentView]), value: .make(use_student_view: true))
        api.mock(GetCustomColors(), value: APICustomColors(custom_colors: ["course_1": "#FF0000"]))
        api.mock(GetCourseNavigationToolsRequest(courseContextsCodes: ["course_1"]), value: [])

        AppEnvironment.shared.app = .student
        let testee = CourseDetailsViewModel(context: .course("1"))
        XCTAssertEqual(testee.state, .loading)
        testee.viewDidAppear()
        drainMainQueue()

        XCTAssertEqual(testee.courseColor.hexString, UIColor(hexString: "#FF0000")!.ensureContrast(against: .backgroundLightest).hexString)
        XCTAssertEqual(testee.homeLabel, nil)
        XCTAssertEqual(testee.homeSubLabel, "Syllabus")
        XCTAssertEqual(testee.homeRoute, URL(string: "courses/1/syllabus")!)

        XCTAssertTrue(testee.showHome)
        XCTAssertFalse(testee.showSettings)
        XCTAssertFalse(testee.showStudentView)
        XCTAssertEqual(testee.courseName, "Course One")
        XCTAssertEqual(testee.navigationBarTitle, "C1")
        XCTAssertEqual(testee.settingsRoute, URL(string: "courses/1/settings")!)
        XCTAssertEqual(testee.courseID, "1")
    }
}
