//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
@testable import Student
import Core

class AssignmentDetailsPresenterTests: XCTestCase {

//    var resultingAssignment: Assignment?
    var resultingError: NSError?
    var presenter: AssignmentDetailsPresenter!
//    var env: AppEnvironment = testEnvironment()
    var expectation = XCTestExpectation(description: "expectation")

    override func setUp() {
//        env = testEnvironment()
        expectation = XCTestExpectation(description: "expectation")
//        presenter = AssignmentDetailsPresenter(env: env)
    }

    func testLoadAssignment() {
        //  given
//        let expected = [Aassignment.make()]
//        frc?.mockObjects = expected

        //  when
//        presenter.loadAssignment()

        //  then
//        XCTAssertEqual(resultingAssignment, expected)
    }

    func testErrorInLoadingTabs() {
        //  given
//        let expected = NSError.instructureError("InternalError")
//        frc?.error = expected

        //  when
//        presenter.loadAssignment()

        //  then
//        XCTAssertEqual(resultingError, expected)
    }

    func testFrcParameters() {

    }

    func testUseCaseIsAddedToQueue() {
//        wait(for: [expectation], timeout: 0.1)
    }
}

extension AssignmentDetailsPresenterTests: AssignmentDetailsViewCompositeDelegate {
//    func showAssignment(_ assignment: Assignment) {
//        resultingAssignment = assignment
//    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }
}
