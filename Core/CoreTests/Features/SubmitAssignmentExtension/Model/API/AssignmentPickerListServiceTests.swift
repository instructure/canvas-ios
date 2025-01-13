//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
@testable import Core
import XCTest

class AssignmentPickerListServiceTests: CoreTestCase {
    private var testee: AssignmentPickerListService!
    private var receivedResult: Result<[APIAssignmentPickerListItem], AssignmentPickerListServiceError>?
    private var resultSubscription: AnyCancellable?

    override func setUp() {
        super.setUp()
        testee = AssignmentPickerListService()

        let resultExpectation = expectation(description: "result received")
        resultSubscription = testee.result.sink { [weak self] result in
            resultExpectation.fulfill()
            self?.receivedResult = result
        }
    }

    override func tearDown() {
        super.tearDown()
        resultSubscription?.cancel()
    }

    func testAPIError() {
        api.mock(AssignmentPickerListRequest(courseID: "failingID"), data: nil, response: nil, error: NSError.instructureError("Custom error"))
        testee.courseID = "failingID"
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(receivedResult, .failure(.failedToGetAssignments))
    }

    func testAssignmentFetchSuccessful() {
        api.mock(AssignmentPickerListRequest(courseID: "successID"), value: mockAssignments([
            mockAssignment(id: "A1", name: "unknown submission type"),
            mockAssignment(id: "A2", name: "online upload", submission_types: [.online_upload]),
            mockAssignment(id: "A3", isLocked: true, name: "online upload, locked", submission_types: [.online_upload]),
            mockAssignment(id: "A4", name: "external tool", submission_types: [.external_tool])
        ]))
        testee.courseID = "successID"
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(receivedResult, .success([
            .init(id: "A2", name: "online upload", allowedExtensions: [], gradeAsGroup: false)
        ]))
    }

    func testGroupGradedAssignmentFetchSuccessful() {
        api.mock(AssignmentPickerListRequest(courseID: "successID"), value: mockAssignments([
            mockAssignment(id: "A1", name: "unknown submission type"),
            mockAssignment(id: "A2", name: "online upload", submission_types: [.online_upload], gradeAsGroup: true),
            mockAssignment(id: "A3", isLocked: true, name: "online upload, locked", submission_types: [.online_upload]),
            mockAssignment(id: "A4", name: "external tool", submission_types: [.external_tool])
        ]))
        testee.courseID = "successID"
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(receivedResult, .success([
            .init(id: "A2", name: "online upload", allowedExtensions: [], gradeAsGroup: true)
        ]))
    }

    func testReportsNumberOfAssignments() {
        let analyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = analyticsHandler

        api.mock(AssignmentPickerListRequest(courseID: "successID"), value: mockAssignments([
            mockAssignment(id: "A1", name: "online upload", submission_types: [.online_upload]),
            mockAssignment(id: "A2", name: "online upload", submission_types: [.online_upload])
        ]))
        testee.courseID = "successID"
        waitForExpectations(timeout: 0.1)

        XCTAssertEqual(analyticsHandler.totalEventCount, 1)
        XCTAssertEqual(analyticsHandler.lastEvent, "assignments_loaded")
        XCTAssertEqual(analyticsHandler.lastEventParameters as? [String: Int], ["count": 2])
    }

    func testReportsAssignmentLoadFailure() {
        let analyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = analyticsHandler

        api.mock(AssignmentPickerListRequest(courseID: "successID"), error: NSError.instructureError("custom error"))
        testee.courseID = "failureID"
        waitForExpectations(timeout: 0.1)

        XCTAssertEqual(analyticsHandler.totalEventCount, 1)
        XCTAssertEqual(analyticsHandler.lastEvent, "error_loading_assignments")
        XCTAssertEqual(analyticsHandler.lastEventParameters as? [String: String], ["error": "custom error"])
    }

    private func mockAssignments(_ assignments: [AssignmentPickerListResponse.Assignment]) -> AssignmentPickerListRequest.Response {
        return AssignmentPickerListRequest.Response(
            data: .init(
                course: .init(
                    assignmentsConnection: .init(
                        nodes: assignments,
                        pageInfo: nil
                    )
                )
            )
        )
    }

    private func mockAssignment(id: String, isLocked: Bool = false, name: String, submission_types: [SubmissionType] = [], gradeAsGroup: Bool = false) -> AssignmentPickerListResponse.Assignment {
        .init(name: name, _id: id, submissionTypes: submission_types, allowedExtensions: [], lockInfo: .init(isLocked: isLocked), gradeAsGroup: gradeAsGroup)
    }
}
