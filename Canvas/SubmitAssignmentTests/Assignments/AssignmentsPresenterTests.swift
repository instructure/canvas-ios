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

import Core
import TestsFoundation
import XCTest

class AssignmentsPresenterTests: SubmitAssignmentTests, AssignmentsView {
    func testViewIsReady() {
        let presenter = AssignmentsPresenter(environment: env, courseID: "1", selectedAssignmentID: nil, callback: { _ in })
        presenter.view = self
        let expectation = XCTestExpectation(description: "update was called")
        Assignment.make(from: .make(course_id: "1"))
        Course.make(from: .make(id: ID(stringLiteral: "1")))
        onUpdate = {
            if !presenter.assignments.isEmpty {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 0.1)
    }

    func testCallback() {
        Assignment.make(from: .make(course_id: "1", name: "Selected Assignment"))
        Course.make(from: .make(id: ID(stringLiteral: "1")))
        let expectation = XCTestExpectation(description: "callback was called")
        var assignment: Assignment?
        let presenter = AssignmentsPresenter(environment: env, courseID: "1", selectedAssignmentID: nil) { a in
            assignment = a
            expectation.fulfill()
        }
        presenter.view = self
        presenter.viewIsReady()
        presenter.selectAssignment(at: IndexPath(row: 0, section: 0))
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(assignment)
        XCTAssertEqual(assignment?.name, "Selected Assignment")
    }

    func testGetNextPage() {
        let expectation = XCTestExpectation(description: "update was not called")
        expectation.isInverted = true
        onUpdate = {
            expectation.fulfill()
        }
        let presenter = AssignmentsPresenter(environment: env, courseID: "1", selectedAssignmentID: nil, callback: { _ in })
        presenter.view = self
        presenter.getNextPage()
        wait(for: [expectation], timeout: 0.1)
    }

    func testSelectedAssignmentID() {
        let selected = AssignmentsPresenter(environment: env, courseID: "1", selectedAssignmentID: "1", callback: { _ in })
        XCTAssertEqual(selected.selectedAssignmentID, "1")

        let notSelected = AssignmentsPresenter(environment: env, courseID: "1", selectedAssignmentID: nil, callback: { _ in })
        XCTAssertEqual(notSelected.selectedAssignmentID, nil)
    }

    var onUpdate: () -> Void = {}
    func update() {
        onUpdate()
    }
}
