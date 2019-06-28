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
