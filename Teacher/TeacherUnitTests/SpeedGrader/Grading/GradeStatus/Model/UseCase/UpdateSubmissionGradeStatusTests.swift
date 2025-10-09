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

@testable import Core
import Combine
@testable import Teacher
import XCTest

class UpdateSubmissionGradeStatusTests: TeacherTestCase {
    var cancellables: Set<AnyCancellable> = []

    func test_makeRequest_successfulUpdate_returnsUpdatedSubmission() {
        let expectedSubmission = APISubmission.make(id: "2")
        let updateRequest = UpdateSubmissionGradeStatusRequest(
            submissionId: "2",
            customGradeStatusId: "custom",
            latePolicyStatus: "late"
        )
        let getSubmissionRequest = GetSubmissionRequest(
            context: .course("1"),
            assignmentID: "3",
            userID: "4"
        )
        api.mock(updateRequest, value: APINoContent())
        api.mock(getSubmissionRequest, value: expectedSubmission)

        // WHEN
        let testee = UpdateSubmissionGradeStatus(
            courseId: "1",
            submissionId: "2",
            assignmentId: "3",
            userId: "4",
            customGradeStatusId: "custom",
            latePolicyStatus: "late"
        )
        let exp = expectation(description: "Updated submission returned")
        var receivedSubmission: APISubmission?
        testee.makeRequest(environment: environment) { submission, _, _ in
            receivedSubmission = submission
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)

        // THEN
        XCTAssertEqual(receivedSubmission, expectedSubmission)
    }

    func test_makeRequest_updateFails_returnsError() {
        let updateRequest = UpdateSubmissionGradeStatusRequest(
            submissionId: "2",
            customGradeStatusId: nil,
            latePolicyStatus: nil
        )
        api.mock(updateRequest, error: TestError.updateFailed)

        // WHEN
        let testee = UpdateSubmissionGradeStatus(
            courseId: "1",
            submissionId: "2",
            assignmentId: "3",
            userId: "4",
            customGradeStatusId: nil,
            latePolicyStatus: nil
        )
        let exp = expectation(description: "Error returned")
        var receivedError: Error?
        testee.makeRequest(environment: environment) { _, _, error in
            receivedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)

        // THEN
        XCTAssertNotNil(receivedError)
    }

    func test_makeRequest_refreshFails_returnsError() {
        let updateRequest = UpdateSubmissionGradeStatusRequest(
            submissionId: "2",
            customGradeStatusId: nil,
            latePolicyStatus: nil
        )
        let getSubmissionRequest = GetSubmissionRequest(
            context: .course("1"),
            assignmentID: "3",
            userID: "4"
        )
        api.mock(updateRequest, value: APINoContent())
        api.mock(getSubmissionRequest, error: TestError.refreshFailed)

        // WHEN
        let testee = UpdateSubmissionGradeStatus(
            courseId: "1",
            submissionId: "2",
            assignmentId: "3",
            userId: "4",
            customGradeStatusId: nil,
            latePolicyStatus: nil
        )
        let exp = expectation(description: "Error returned")
        var receivedError: Error?
        testee.makeRequest(environment: environment) { _, _, error in
            receivedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)

        // THEN
        XCTAssertNotNil(receivedError)
    }
}

private enum TestError: Error {
    case updateFailed
    case refreshFailed
}
