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
import Core
import Social

class SubmitAssignmentViewControllerTests: SubmitAssignmentTests {
    var viewController: SubmitAssignmentViewController!

    var configurationItems: [SLComposeSheetConfigurationItem]? {
        return viewController.configurationItems() as? [SLComposeSheetConfigurationItem]
    }

    override func setUp() {
        super.setUp()
        LoginSession.add(.make())
        viewController = SubmitAssignmentViewController()
        load()
    }

    func load() {
        XCTAssertNotNil(viewController.view)
        env.api = URLSessionAPI()
        env.database = database
        env.userDefaults?.reset()
    }

    func testSelectsFirstCourseAndAssignmentByDefault() throws {
        let presenter = try XCTUnwrap(viewController.presenter)
        api.mock(presenter.courses, value: [.make(name: "Course 1")])
        api.mock(GetSubmittableAssignments(courseID: "1"), value: [.make(name: "Assignment 1", submission_types: [.online_upload])])
        viewController.presentationAnimationDidFinish()
        drainMainQueue()
        XCTAssertEqual(configurationItems?.count, 2)
        XCTAssertEqual(configurationItems?.first?.title, "Course")
        XCTAssertEqual(configurationItems?.first?.value, "Course 1")
        XCTAssertEqual(configurationItems?.last?.title, "Assignment")
        XCTAssertEqual(configurationItems?.last?.value, "Assignment 1")
    }

    func testDefaultCourseDoesNotOverrideSelected() throws {
        env.userDefaults?.submitAssignmentCourseID = "1"
        env.userDefaults?.submitAssignmentID = "2"
        let task = api.mock(GetCourse(courseID: "1"), value: .make(id: "1", name: "Default"))
        task.paused = true
        viewController.presentationAnimationDidFinish()
        drainMainQueue()
        viewController.presenter?.select(course: Course.make(from: .make(id: "2", name: "Selected")))
        drainMainQueue()
        task.paused = false
        drainMainQueue()
        let course = try XCTUnwrap(configurationItems?.first)
        XCTAssertEqual(course.value, "Selected")
    }

    func testDefaultAssignmentDoesNotOverrideSelected() throws {
        env.userDefaults?.submitAssignmentCourseID = "1"
        env.userDefaults?.submitAssignmentID = "2"
        api.mock(GetCourse(courseID: "1"), value: .make(id: "1"))
        let task = api.mock(GetAssignment(courseID: "1", assignmentID: "2"), value: .make(id: "2", name: "Default"))
        task.paused = true
        viewController.presentationAnimationDidFinish()
        drainMainQueue()
        XCTAssertEqual(configurationItems?.count, 2)
        var assignment = try XCTUnwrap(configurationItems?.last)
        XCTAssertTrue(assignment.valuePending)
        viewController.presenter?.select(assignment: Assignment.make(from: .make(id: "3", name: "Selected")))
        drainMainQueue()
        task.paused = false
        drainMainQueue()
        XCTAssertEqual(configurationItems?.count, 2)
        assignment = try XCTUnwrap(configurationItems?.last)
        XCTAssertEqual(assignment.value, "Selected")
    }
}
