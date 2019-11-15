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

import XCTest
@testable import Core
import TestsFoundation

class GradesPresenterTests: CoreTestCase {
    var resultingError: NSError?
    var resultingBackgroundColor: UIColor?
    var presenter: GradesPresenter!
    var expectation = XCTestExpectation(description: "presenter updated")
    let courseID = "1"
    let studentID = "1"

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "presenter updated")
        environment.mockStore = false
        presenter = GradesPresenter(env: environment, view: self, courseID: courseID, studentID: studentID)
    }

    func testViewIsReady() {
        Course.make()
        let b1: APIAssignment = APIAssignment.make(id: "1", due_at: Date().addDays(-4))
        let a1: APIAssignment = APIAssignment.make(id: "2", due_at: Date().addDays(-3))
        let a2: APIAssignment = APIAssignment.make(id: "3", due_at: Date().addDays(-2))
        let c1: APIAssignment = APIAssignment.make(id: "4", due_at: Date().addDays(-1))

        let req = GetAssignmentsRequest(courseID: courseID, orderBy: .position, include: [.observed_users, .submission], querySize: 99)
        let v: [APIAssignment] = [b1, a1, a2, c1]
        api.mock(req, value: v, response: nil, error: nil)

        presenter.refresh()
        wait(for: [expectation], timeout: 0.5)

        XCTAssertEqual(presenter.assignments[IndexPath(row: 0, section: 0)]?.id, "1")
        XCTAssertEqual(presenter.assignments[IndexPath(row: 0, section: 1)]?.id, "2")
        XCTAssertEqual(presenter.assignments[IndexPath(row: 0, section: 2)]?.id, "3")
        XCTAssertEqual(presenter.assignments[IndexPath(row: 0, section: 3)]?.id, "4")
    }
}

extension GradesPresenterTests: GradesViewProtocol {
    func updateScore(_ score: String?) {
    }

    func update(isLoading: Bool) {
        if !isLoading { expectation.fulfill() }
    }

    func showAlert(title: String?, message: String?) {}
}
