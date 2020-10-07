//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import TestsFoundation

class ConversationCoursesActionSheetTests: CoreTestCase {
    lazy var controller = ConversationCoursesActionSheet.create(delegate: self)

    let selectedExpectation = XCTestExpectation(description: "selected")
    var selectedCourse: Course?
    var selectedUser: User?

    override func setUp() {
        super.setUp()
        environment.mockStore = true
    }

    func loadView() {
        controller.view.frame = CGRect(x: 0, y: 0, width: 300, height: 800)
        controller.viewDidLoad()
    }

    func testLayout() {
        loadView()
        let loadingIndicator = controller.view.subviews.last as! UIActivityIndicatorView
        XCTAssertTrue(loadingIndicator.isAnimating)

        let enrollments = controller.enrollments as! TestStore
        wait(for: [enrollments.exhaustExpectation], timeout: 0.1)
    }

    func testActivityIndicator() {
        environment.mockStore = false

        let enrollmentsTask = api.mock(GetEnrollmentsRequest(context: .currentUser,
                                                             userID: nil,
                                                             gradingPeriodID: nil,
                                                             types: ["ObserverEnrollment"],
                                                             includes: [.observed_users]),
                                       value: [])
        let coursesTask = api.mock(GetCoursesRequest(enrollmentState: .active, state: nil, perPage: 100))

        enrollmentsTask.suspend()
        coursesTask.suspend()

        loadView()

        XCTAssertTrue(controller.loadingIndicator.isAnimating)

        enrollmentsTask.resume()
        coursesTask.resume()

        XCTAssertFalse(controller.loadingIndicator.isAnimating)
    }

    func testShowError() {
        environment.mockStore = false
        api.mock(GetEnrollmentsRequest(context: .currentUser,
                                       userID: nil,
                                       gradingPeriodID: nil,
                                       types: ["ObserverEnrollment"],
                                       includes: [.observed_users]),
                 error: NSError.instructureError("The Message"))

        loadView()

        XCTAssert(router.presented is UIAlertController)
    }

    func testNumberOfRowsInSection() {
        loadView()

        XCTAssertEqual(controller.tableView(controller.tableView, numberOfRowsInSection: 0), 0)

        Enrollment.make(from: .make(course_id: "1", type: "ObserverEnrollment", observed_user: .make()), course: .make(from: .make(id: "1"), in: databaseClient), in: databaseClient)
        XCTAssertEqual(controller.tableView(controller.tableView, numberOfRowsInSection: 0), 1)
    }

    func testCellForRowAt() {
        let enrollment = Enrollment.make(
            from: .make(
                course_id: "1",
                type: "ObserverEnrollment",
                observed_user: .make(name: "Long Name", short_name: "Observed User")),
            course: .make(from: .make(id: "1"))
        )
        loadView()

        let cell = controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell.textLabel?.text, enrollment.course?.name)
        XCTAssertEqual(cell.detailTextLabel?.text, "for Observed User")
    }

    func testCellForRowAtPronouns() {
        let enrollment = Enrollment.make(
            from: .make(
                course_id: "1",
                type: "ObserverEnrollment",
                observed_user: .make(name: "Eve Long", short_name: "Eve", pronouns: "She/Her")),
            course: .make(from: .make(id: "1"))
        )
        loadView()

        let cell = controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell.textLabel?.text, enrollment.course?.name)
        XCTAssertEqual(cell.detailTextLabel?.text, "for Eve (She/Her)")
    }

    func testCellTapped() {
        let apiUser = APIUser.make()
        let course = Course.make()
        User.make(from: apiUser, courseID: "1", groupID: nil, in: databaseClient)
        let enrollment = Enrollment.make(from: .make(course_id: "1", type: "ObserverEnrollment", observed_user: apiUser), course: course, in: databaseClient)

        loadView()

        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        wait(for: [selectedExpectation], timeout: 1)
        XCTAssertEqual(selectedCourse, enrollment.course)
        XCTAssertEqual(selectedUser, enrollment.observedUser)
    }
}

extension ConversationCoursesActionSheetTests: ConversationCoursesActionSheetDelegate {
    func courseSelected(course: Course, user: User) {
        selectedCourse = course
        selectedUser = user
        selectedExpectation.fulfill()
    }
}
