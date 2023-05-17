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

@testable import Core
import Foundation
import TestsFoundation
import XCTest

class CourseSyncAssignmentsInteractorLiveTests: CoreTestCase {
    func testAssignments() {
        let testee = CourseSyncAssignmentsInteractorLive()
        let expectation = expectation(description: "Publisher sends value")

        api.mock(GetAssignmentGroups(courseID: "1"), value: [.make(assignments: [.make()])])

        let subscription = testee.getContent(courseId: "1")
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    expectation.fulfill()
                }
            )

        waitForExpectations(timeout: 0.1)
        let assignmentList: [Assignment] = databaseClient.fetch(nil, sortDescriptors: nil)
        XCTAssertEqual(assignmentList.count, 1)
        XCTAssertEqual(assignmentList[0].id, "1")
        subscription.cancel()
    }

    func testErrorHandling() {
        let testee = CourseSyncAssignmentsInteractorLive()
        let expectation = expectation(description: "Publisher sends value")

        api.mock(GetAssignmentGroups(courseID: "1"), error: NSError.instructureError("Assignments not found"))

        let subscription = testee.getContent(courseId: "1")
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure:
                        expectation.fulfill()
                    default:
                        break
                    }
                },
                receiveValue: { _ in }
            )

        waitForExpectations(timeout: 0.1)
        let assignmentList: [Assignment] = databaseClient.fetch(nil, sortDescriptors: nil)
        XCTAssertEqual(assignmentList.count, 0)
        subscription.cancel()
    }
}
