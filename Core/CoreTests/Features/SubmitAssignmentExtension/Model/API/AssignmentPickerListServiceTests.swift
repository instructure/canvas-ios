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

    private var expectation: XCTestExpectation?

    private func expect() {
        expectation = expectation(description: "result received")
    }

    override func setUp() {
        super.setUp()
        testee = AssignmentPickerListService()

        resultSubscription = testee.result.sink { [weak self] result in
            self?.expectation?.fulfill()
            self?.receivedResult = result
        }
    }

    override func tearDown() {
        super.tearDown()
        resultSubscription?.cancel()
    }

    func testAPIError() {
        api.mock(AssignmentPickerListRequest(courseID: "failingID"), data: nil, response: nil, error: NSError.instructureError("Custom error"))

        expect()
        testee.courseID = "failingID"

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(receivedResult, .failure(.failedToGetAssignments))
    }

    func testAssignmentFetchSuccessful() {
        api.mock(AssignmentPickerListRequest(courseID: "successID"), value: mockAssignments([
            .make(id: "A1", name: "unknown submission type"),
            .make(id: "A2", name: "online upload", submission_types: [.online_upload]),
            .make(id: "A3", name: "online upload, locked", submission_types: [.online_upload], isLocked: true),
            .make(id: "A4", name: "external tool", submission_types: [.external_tool])
        ]))

        expect()
        testee.courseID = "successID"

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(receivedResult, .success([
            .init(id: "A2", name: "online upload", allowedExtensions: [], gradeAsGroup: false)
        ]))
    }

    func testAssignment_NextPage_Fetch() {
        // First Fetch
        api.mock(
            AssignmentPickerListRequest(courseID: "successID"),
            value: mockAssignments(
                [
                    .make(id: "A1", name: "Assignment 1", submission_types: [.online_upload]),
                    .make(id: "A2", name: "Assignment 2", submission_types: [.online_upload])
                ],
                pageInfo: APIPageInfo(endCursor: "next_cursor", hasNextPage: true)
            )
        )

        expect()
        testee.courseID = "successID"

        waitForExpectations(timeout: 5)
        XCTAssertEqual(receivedResult, .success([
            .init(id: "A1", name: "Assignment 1", allowedExtensions: [], gradeAsGroup: false),
            .init(id: "A2", name: "Assignment 2", allowedExtensions: [], gradeAsGroup: false)
        ]))

        // Next Page Fetch
        api.mock(
            AssignmentPickerListRequest(courseID: "successID", cursor: "next_cursor"),
            value: mockAssignments(
                [
                    .make(id: "A3", name: "Assignment 3", submission_types: [.online_upload]),
                    .make(id: "A4", name: "Assignment 4", submission_types: [.online_upload])
                ],
                pageInfo: APIPageInfo(endCursor: "final_cursor", hasNextPage: false)
            )
        )

        expect()
        testee.loadNextPage()

        waitForExpectations(timeout: 5)
        XCTAssertEqual(receivedResult, .success([
            .init(id: "A1", name: "Assignment 1", allowedExtensions: [], gradeAsGroup: false),
            .init(id: "A2", name: "Assignment 2", allowedExtensions: [], gradeAsGroup: false),
            .init(id: "A3", name: "Assignment 3", allowedExtensions: [], gradeAsGroup: false),
            .init(id: "A4", name: "Assignment 4", allowedExtensions: [], gradeAsGroup: false)
        ]))

        // Final Fetch
        api.mock(
            AssignmentPickerListRequest(courseID: "successID", cursor: "final_cursor"),
            value: mockAssignments(
                [],
                pageInfo: nil
            )
        )

        expect()
        testee.loadNextPage { [weak self] in
            self?.expectation?.fulfill()
        }

        waitForExpectations(timeout: 5)
        XCTAssertEqual(receivedResult, .success([
            .init(id: "A1", name: "Assignment 1", allowedExtensions: [], gradeAsGroup: false),
            .init(id: "A2", name: "Assignment 2", allowedExtensions: [], gradeAsGroup: false),
            .init(id: "A3", name: "Assignment 3", allowedExtensions: [], gradeAsGroup: false),
            .init(id: "A4", name: "Assignment 4", allowedExtensions: [], gradeAsGroup: false)
        ]))
    }

    func testGroupGradedAssignmentFetchSuccessful() {
        api.mock(AssignmentPickerListRequest(courseID: "successID"), value: mockAssignments([
            .make(id: "A1", name: "unknown submission type"),
            .make(id: "A2", name: "online upload", submission_types: [.online_upload], gradeAsGroup: true),
            .make(id: "A3", name: "online upload, locked", submission_types: [.online_upload], isLocked: true),
            .make(id: "A4", name: "external tool", submission_types: [.external_tool])
        ]))

        expect()
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
            .make(id: "A1", name: "online upload", submission_types: [.online_upload]),
            .make(id: "A2", name: "online upload", submission_types: [.online_upload])
        ]))

        expect()
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

        expect()
        testee.courseID = "failureID"
        waitForExpectations(timeout: 0.1)

        XCTAssertEqual(analyticsHandler.totalEventCount, 1)
        XCTAssertEqual(analyticsHandler.lastEvent, "error_loading_assignments")
        XCTAssertEqual(analyticsHandler.lastEventParameters as? [String: String], ["error": "custom error"])
    }

    private func mockAssignments(_ assignments: [AssignmentPickerListResponse.Assignment], pageInfo: APIPageInfo? = nil) -> AssignmentPickerListRequest.Response {
        return AssignmentPickerListRequest.Response(
            data: .init(
                course: .init(
                    assignmentsConnection: .init(
                        nodes: assignments,
                        pageInfo: pageInfo
                    )
                )
            )
        )
    }
}
