//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Combine
import CoreData
import XCTest
@testable import Core

class AssignmentDueDatesInteractorLiveTests: CoreTestCase {
    private var testee: AssignmentDueDatesInteractorLive!
    private let courseID = "1"
    private let assignmentID = "2"

    override func setUp() {
        super.setUp()

        let getAssignmentRequest = GetAssignment(courseID: courseID, assignmentID: assignmentID)
        let apiAssignment = APIAssignment.make(
            all_dates: [
                .make(
                    id: 1,
                    title: "nodue",
                    due_at: nil
                ),
                .make(
                    id: 2,
                    title: "june",
                    due_at: DateComponents(calendar: .current, year: 2023, month: 6, day: 1).date
                ),
                .make(
                    id: 3,
                    title: "april",
                    due_at: DateComponents(calendar: .current, year: 2023, month: 4, day: 2).date
                ),
            ],
            id: ID(assignmentID)
        )
        api.mock(getAssignmentRequest, value: apiAssignment)
        testee = AssignmentDueDatesInteractorLive(env: environment, courseID: courseID, assignmentID: assignmentID)

        waitForState(.data)
    }

    func testPopulatesListItems() {
        XCTAssertEqual(testee.state.value, .data)
        XCTAssertEqual(testee.dueDates.value.count, 3)
        XCTAssertEqual(testee.dueDates.value.first?.title, "april")
    }

    private func waitForState(_ state: StoreState) {
        let stateUpdate = expectation(description: "Expected state reached")
        stateUpdate.assertForOverFulfill = false
        let subscription = testee
            .state
            .sink {
                if $0 == state {
                    stateUpdate.fulfill()
                }
            }
        wait(for: [stateUpdate], timeout: 1)
        subscription.cancel()
    }
}
