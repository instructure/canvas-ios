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

    var resultingAssignmentsByGroup: [[GradesPresenter.CellViewModel]] = []
    var resultingGroups = [String]()

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "presenter updated")
        presenter = GradesPresenter(env: environment, view: self, courseID: courseID)
    }

    func testViewIsReady() {
        Course.make()
        let assignmentB = APIAssignment.make(id: "1", assignment_group_id: "1")

        let assignmentA1 = APIAssignment.make(id: "2", assignment_group_id: "2")
        let assignmentA2 = APIAssignment.make(id: "3", assignment_group_id: "2")

        let assignmentC1 = APIAssignment.make(id: "4", assignment_group_id: "3")

        AssignmentGroup.make(from: APIAssignmentGroup.make(id: "3", name: "c", position: 3, assignments: [assignmentC1]), courseID: courseID, in: databaseClient)
        AssignmentGroup.make(from: APIAssignmentGroup.make(id: "1", name: "b", position: 2, assignments: [assignmentB]), courseID: courseID, in: databaseClient)
        AssignmentGroup.make(from: APIAssignmentGroup.make(id: "2", name: "a", position: 1, assignments: [assignmentA1, assignmentA2]), courseID: courseID, in: databaseClient)

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 0.5)

        XCTAssertEqual(resultingGroups, ["a", "b", "c"])
        let str = resultingAssignmentsByGroup.map { "\($0.count)" }.joined(separator: " ")
        XCTAssertEqual(str, "2 1 1")
    }
}

extension GradesPresenterTests: GradesViewProtocol {
    func update(groups: [String], assignmentsByGroup: [[GradesPresenter.CellViewModel]]) {
        resultingGroups = groups
        resultingAssignmentsByGroup = assignmentsByGroup
        expectation.fulfill()
    }

    var navigationController: UINavigationController? {
        return nil
    }
}
