//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class CoursePickerViewModelTests: CoreTestCase {

    override func tearDown() {
        super.tearDown()
        environment.userDefaults?.submitAssignmentCourseID = nil
    }

    func testUnknownAPIError() {
        let testee = CoursePickerViewModel()
        XCTAssertNil(testee.selectedCourse)
        XCTAssertEqual(testee.state, .error("Something went wrong"))
    }

    func testAPIError() {
        api.mock(GetCoursesRequest(enrollmentState: .active, perPage: 100), data: nil, response: nil, error: NSError.instructureError("Custom error"))
        let testee = CoursePickerViewModel()
        XCTAssertNil(testee.selectedCourse)
        XCTAssertEqual(testee.state, .error("Custom error"))
    }

    func testCourseFetchSuccessful() {
        api.mock(GetCoursesRequest(enrollmentState: .active, perPage: 100), value: [
            APICourse.make(id: "testCourse1_ID", name: "testCourse1"),
            APICourse.make(id: "testCourse2_ID", name: "testCourse2"),
            APICourse.make(id: "testCourse3_ID", name: nil)
        ])
        let testee = CoursePickerViewModel()
        XCTAssertNil(testee.selectedCourse)
        XCTAssertEqual(testee.state, .data([
            .init(id: "testCourse1_ID", name: "testCourse1"),
            .init(id: "testCourse2_ID", name: "testCourse2")
        ]))
    }

    func testDefaultCourseSelection() {
        environment.userDefaults?.submitAssignmentCourseID = "testCourse2_ID"
        api.mock(GetCoursesRequest(enrollmentState: .active, perPage: 100), value: [
            APICourse.make(id: "testCourse1_ID", name: "testCourse1"),
            APICourse.make(id: "testCourse2_ID", name: "testCourse2")
        ])
        let testee = CoursePickerViewModel()
        XCTAssertEqual(testee.selectedCourse, .init(id: "testCourse2_ID", name: "testCourse2"))
        XCTAssertEqual(testee.state, .data([
            .init(id: "testCourse1_ID", name: "testCourse1"),
            .init(id: "testCourse2_ID", name: "testCourse2")
        ]))
        // Keep the course ID so if the user submits another attempt without starting the app we'll pre-select
        XCTAssertNotNil(environment.userDefaults?.submitAssignmentCourseID)
    }

    func testPreviewInitializer() {
        let testee = CoursePickerViewModel(state: .loading)
        XCTAssertNil(testee.selectedCourse)
        XCTAssertEqual(testee.state, .loading)
    }

    func testReportsCourseSelectionToAnalytics() {
        let analyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = analyticsHandler
        let testee = CoursePickerViewModel()
        XCTAssertEqual(analyticsHandler.totalEventCount, 1) // courses loaded event

        testee.courseSelected(.init(id: "", name: ""))

        XCTAssertEqual(analyticsHandler.totalEventCount, 2)
        XCTAssertEqual(analyticsHandler.lastEvent, "course_selected")
        XCTAssertNil(analyticsHandler.lastEventParameters)
    }

    func testReportsNumberOfCourses() {
        let analyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = analyticsHandler
        api.mock(GetCoursesRequest(enrollmentState: .active, perPage: 100), value: [
            APICourse.make(id: "testCourse1_ID", name: "testCourse1"),
            APICourse.make(id: "testCourse2_ID", name: "testCourse2")
        ])

        _ = CoursePickerViewModel()

        XCTAssertEqual(analyticsHandler.totalEventCount, 1)
        XCTAssertEqual(analyticsHandler.lastEvent, "courses_loaded")
        XCTAssertEqual(analyticsHandler.lastEventParameters as? [String: Int], ["count": 2])
    }

    func testReportsCourseLoadFailure() {
        let analyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = analyticsHandler

        api.mock(GetCoursesRequest(enrollmentState: .active, perPage: 100), error: NSError.instructureError("custom error"))

        _ = CoursePickerViewModel()

        XCTAssertEqual(analyticsHandler.totalEventCount, 1)
        XCTAssertEqual(analyticsHandler.lastEvent, "error_loading_courses")
        XCTAssertEqual(analyticsHandler.lastEventParameters as? [String: String], ["error": "custom error"])
    }
}
