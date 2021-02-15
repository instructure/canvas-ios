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

import Foundation
import XCTest
@testable import Core
import TestsFoundation

class PlannerFilterViewControllerTests: CoreTestCase {
    var studentID: String? = "1"
    lazy var controller = PlannerFilterViewController.create(studentID: studentID)

    lazy var course1 = APICourse.make(
        id: "1",
        name: "BIO 101",
        enrollments: [
            .make(type: "observer", associated_user_id: studentID),
        ]
    )
    lazy var course2 = APICourse.make(
        id: "2",
        name: "BIO 102",
        enrollments: [
            .make(type: "observer", associated_user_id: studentID),
        ]
    )

    func testLayout() {
        api.mock(controller.courses.useCase.request, value: [course1])
        controller.view.layoutIfNeeded()
        let tableView = controller.tableView!
        XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0), 1)
        var cell1 = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! PlannerFilterCell
        XCTAssertEqual(cell1.courseNameLabel.text, "BIO 101")
        XCTAssertTrue(cell1.isSelected)
        tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        cell1 = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! PlannerFilterCell
        XCTAssertFalse(cell1.isSelected)
    }

    func testPaginatedRefresh() {
        controller.view.layoutIfNeeded()
        let next = HTTPURLResponse(next: "/courses?page=2")
        api.mock(controller.courses.useCase.request, value: [course1], response: next)
        api.mock(GetNextRequest(path: "/courses?page=2"), value: [course2])
        let tableView = controller.tableView!
        tableView.refreshControl?.sendActions(for: .valueChanged)
        XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0), 2)
        let loading = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? LoadingCell
        XCTAssertNotNil(loading)
        XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0), 2)
        let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! PlannerFilterCell
        XCTAssertEqual(cell.courseNameLabel.text, course2.name)
    }

    func testLoadingState() {
        let task = api.mock(controller.courses.useCase.request, value: [])
        task.suspend()
        controller.view.layoutIfNeeded()
        XCTAssertFalse(controller.spinnerView.isHidden)
        task.resume()
        XCTAssertTrue(controller.spinnerView.isHidden)
    }

    func testErrorAndEmptyState() {
        api.mock(controller.courses.useCase.request, error: NSError.instructureError("fail"))
        controller.view.layoutIfNeeded()
        XCTAssertFalse(controller.errorView.isHidden)
        XCTAssertEqual(controller.errorView.messageLabel.text, "There was an error loading courses. Pull to refresh to try again.")
        api.mock(controller.courses.useCase.request, value: [])
        controller.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(controller.errorView.isHidden)
        XCTAssertFalse(controller.emptyStateView.isHidden)
        XCTAssertEqual(controller.emptyTitleLabel.text, "No Courses")
        XCTAssertEqual(controller.emptyMessageLabel.text, "Your child's courses might not be published yet.")
    }

    func testShowsObserveeCoursesForObserversWithPagination() {
        environment.app = .parent
        let match = APICourse.make(
            id: "1",
            name: "Observed Course",
            enrollments: [.make(id: "1", associated_user_id: studentID)]
        )
        let notAMatch = APICourse.make(
            id: "2",
            name: "Other observee",
            enrollments: [.make(id: "2", associated_user_id: "2000")]
        )
        let next = HTTPURLResponse(next: "/courses?page=2")
        api.mock(GetNextRequest(path: "/courses?page=2"), value: [match])
        api.mock(GetCoursesRequest(
            enrollmentState: .active,
            enrollmentType: .observer,
            state: [.available],
            perPage: 100,
            studentID: nil
        ), value: [notAMatch], response: next)
        controller.view.layoutIfNeeded()
        let tableView = controller.tableView!
        XCTAssertEqual(controller.tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0), 1)
        let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! PlannerFilterCell
        print(cell)
        XCTAssertEqual(cell.courseNameLabel.text, "Observed Course")
    }
}
