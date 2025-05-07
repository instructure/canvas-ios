//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import CombineSchedulers
import CoreData
import XCTest
@testable import Core
@testable import Teacher

class SubmissionListInteractorLiveTests: TeacherTestCase {
    
    enum TestConstants {
        static let assignmentID = "12345"
        static let courseID = "67890"

        static var context: Context {
            return .course(courseID)
        }
    }

    private var subscriptions = Set<AnyCancellable>()

    override func tearDown() {
        subscriptions.removeAll()
        super.tearDown()
    }

    func makeInteractor(filters: [GetSubmissions.Filter] = []) -> SubmissionListInteractorLive {
        return SubmissionListInteractorLive(
            context: TestConstants.context,
            assignmentID: TestConstants.assignmentID,
            filters: filters,
            env: environment
        )
    }

    func testInitialization() {
        let interactor = makeInteractor()

        XCTAssertEqual(interactor.assignmentID, TestConstants.assignmentID)
        XCTAssertEqual(interactor.context, TestConstants.context)
    }

    func testSubmissionFetch() {
        // Given
        api.mock(
            GetSubmissions(
                context: TestConstants.context,
                assignmentID: TestConstants.assignmentID
            ),
            value: [
                .make(id: "s1", score: 5, user: .make(id: "u1", name: "John"), user_id: "u1"),
                .make(id: "s2", score: 2, user: .make(id: "u2", name: "Jane"), user_id: "u2"),
                .make(id: "s3", user: .make(id: "u3", name: "Smith"), user_id: "u3")
            ]
        )

        // When
        let interactor = makeInteractor()
        interactor.submissions.sink { list in
            XCTAssertEqual(list.count, 3)

            // Then
            XCTAssertEqual(list[0].id, "s1")
            XCTAssertEqual(list[0].userID, "u1")
            XCTAssertEqual(list[0].user?.name, "John")
            XCTAssertEqual(list[0].score, 5)

            XCTAssertEqual(list[1].id, "s2")
            XCTAssertEqual(list[1].userID, "u2")
            XCTAssertEqual(list[1].user?.name, "Jane")
            XCTAssertEqual(list[1].score, 2)

            XCTAssertEqual(list[2].id, "s3")
            XCTAssertEqual(list[2].userID, "u3")
            XCTAssertEqual(list[2].user?.name, "Smith")
            XCTAssertNil(list[2].score)
        }
        .store(in: &subscriptions)
    }

    func testAssignmentFetch() {
        // Given
        api.mock(
            GetAssignment(
                courseID: TestConstants.courseID,
                assignmentID: TestConstants.assignmentID
            ),
            value: .make(
                id: ID(rawValue: TestConstants.assignmentID),
                name: "Test Assignment"
            )
        )

        // When
        let interactor = makeInteractor()
        interactor.assignment.sink { assignment in

            // Then
            XCTAssertEqual(assignment?.id, TestConstants.assignmentID)
            XCTAssertEqual(assignment?.name, "Test Assignment")
        }
        .store(in: &subscriptions)
    }

    func testCourseFetch() {
        // Given
        api.mock(
            GetCourse(courseID: TestConstants.courseID),
            value: .make(id: ID(TestConstants.courseID), name: "Test Course")
        )

        // When
        let interactor = makeInteractor()
        interactor.course.sink { course in

            // Then
            XCTAssertEqual(course?.id, TestConstants.courseID)
            XCTAssertEqual(course?.name, "Test Course")
        }
        .store(in: &subscriptions)
    }

    func testRefresh() {
        // Given
        api.mock(
            GetAssignment(
                courseID: TestConstants.courseID,
                assignmentID: TestConstants.assignmentID
            ),
            value: .make(
                id: ID(rawValue: TestConstants.assignmentID),
                name: "Test Assignment"
            )
        )

        // When
        var callOrder = 1
        let interactor = makeInteractor()

        let assignmentExp1 = expectation(description: "assignment checked 1")
        let assignmentExp2 = expectation(description: "assignment checked 2")

        interactor.assignment.sink { assignment in
            if callOrder == 1 {
                XCTAssertEqual(assignment?.id, TestConstants.assignmentID)
                XCTAssertEqual(assignment?.name, "Test Assignment")
                assignmentExp1.fulfill()
            } else {
                XCTAssertEqual(assignment?.id, TestConstants.assignmentID)
                XCTAssertEqual(assignment?.name, "Example Assignment")
                assignmentExp2.fulfill()
            }
        }
        .store(in: &subscriptions)

        wait(for: [assignmentExp1], timeout: 5)

        // Tweaking data

        api.mock(
            GetAssignment(
                courseID: TestConstants.courseID,
                assignmentID: TestConstants.assignmentID
            ),
            value: .make(
                id: ID(rawValue: TestConstants.assignmentID),
                name: "Example Assignment"
            )
        )

        callOrder = 2

        let exp = expectation(description: "Refreshed")
        interactor.refresh().sink {
            exp.fulfill()
        }.store(in: &subscriptions)

        wait(for: [exp, assignmentExp2], timeout: 5)
    }
}
