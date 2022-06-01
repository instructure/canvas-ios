//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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
import XCTest

class AssignmentPickerViewModelTests: CoreTestCase {
    private var testee: AssignmentPickerViewModel!

    override func setUp() {
        super.setUp()
        testee = AssignmentPickerViewModel()
        environment.userDefaults?.reset()
    }

    func testUnknownAPIError() {
        testee.courseID = "failingID"
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .error("Something went wrong"))
    }

    func testAPIError() {
        api.mock(AssignmentPickerListRequest(courseID: "failingID"), data: nil, response: nil, error: NSError.instructureError("Custom error"))
        testee.courseID = "failingID"
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .error("Custom error"))
    }

    func testAssignmentFetchSuccessful() {
        api.mock(AssignmentPickerListRequest(courseID: "successID"), value: mockAssignments([
            mockAssignment(id: "A1", name: "unknown submission type"),
            mockAssignment(id: "A2", name: "online upload", submission_types: [.online_upload]),
            mockAssignment(id: "A3", isLocked: true, name: "online upload, locked", submission_types: [.online_upload]),
            mockAssignment(id: "A4", name: "external tool", submission_types: [.external_tool]),
        ]))
        testee.courseID = "successID"
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A2", name: "online upload"),
        ]))
    }

    func testSameCourseIdDoesntTriggerRefresh() {
        api.mock(AssignmentPickerListRequest(courseID: "successID"), value: mockAssignments([
            mockAssignment(id: "A1", name: "online upload", submission_types: [.online_upload]),
        ]))
        testee.courseID = "successID"
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A1", name: "online upload"),
        ]))

        api.mock(AssignmentPickerListRequest(courseID: "failingID"), data: nil, response: nil, error: NSError.instructureError("Custom error"))
        testee.courseID = "successID"
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A1", name: "online upload"),
        ]))
    }

    func testDefaultAssignmentSelection() {
        environment.userDefaults?.submitAssignmentID = "A2"
        api.mock(AssignmentPickerListRequest(courseID: "successID"), value: mockAssignments([
            mockAssignment(id: "A2", name: "online upload", submission_types: [.online_upload]),
        ]))
        testee.courseID = "successID"
        XCTAssertEqual(testee.selectedAssignment, .init(id: "A2", name: "online upload"))
        XCTAssertEqual(testee.state, .data([
            .init(id: "A2", name: "online upload"),
        ]))
        // Keep the assignment ID so if the user submits another attempt without starting the app we'll pre-select
        XCTAssertNotNil(environment.userDefaults?.submitAssignmentID)
    }

    func testCourseChangeRefreshesState() {
        api.mock(AssignmentPickerListRequest(courseID: "successID"), value: mockAssignments([
            mockAssignment(id: "A1", name: "online upload", submission_types: [.online_upload]),
        ]))
        testee.courseID = "successID"
        XCTAssertEqual(testee.state, .data([
            .init(id: "A1", name: "online upload"),
        ]))

        testee.selectedAssignment = .init(id: "A1", name: "online upload")
        api.mock(AssignmentPickerListRequest(courseID: "successID2"), value: mockAssignments([
            mockAssignment(id: "A2", name: "online upload", submission_types: [.online_upload]),
        ]))
        testee.courseID = "successID2"
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A2", name: "online upload"),
        ]))
    }

    func testPreviewInitializer() {
        let testee = AssignmentPickerViewModel(state: .loading)
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .loading)
    }

    func testReportsAssignmentSelectionToAnalytics() {
        let analyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = analyticsHandler
        XCTAssertEqual(analyticsHandler.loggedEventCount, 0)

        testee.assignmentSelected(.init(id: "", name: ""))

        XCTAssertEqual(analyticsHandler.loggedEventCount, 1)
        XCTAssertEqual(analyticsHandler.lastEventName, "assignment_selected")
        XCTAssertNil(analyticsHandler.lastEventParameters)
    }

    func testReportsNumberOfAssignments() {
        let analyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = analyticsHandler

        api.mock(AssignmentPickerListRequest(courseID: "successID"), value: mockAssignments([
            mockAssignment(id: "A1", name: "online upload", submission_types: [.online_upload]),
            mockAssignment(id: "A2", name: "online upload", submission_types: [.online_upload]),
        ]))
        testee.courseID = "successID"

        XCTAssertEqual(analyticsHandler.loggedEventCount, 1)
        XCTAssertEqual(analyticsHandler.lastEventName, "assignments_loaded")
        XCTAssertEqual(analyticsHandler.lastEventParameters as? [String: Int], ["count": 2])
    }

    func testReportsAssignmentLoadFailure() {
        let analyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = analyticsHandler

        api.mock(AssignmentPickerListRequest(courseID: "successID"), error: NSError.instructureError("custom error"))
        testee.courseID = "failureID"

        XCTAssertEqual(analyticsHandler.loggedEventCount, 1)
        XCTAssertEqual(analyticsHandler.lastEventName, "error_loading_assignments")
        XCTAssertEqual(analyticsHandler.lastEventParameters as? [String: String], ["error": "custom error"])
    }

    private func mockAssignments(_ assignments: [AssignmentPickerListResponse.Assignment]) -> AssignmentPickerListRequest.Response {
        return AssignmentPickerListRequest.Response(data: .init(course: .init(assignmentsConnection: .init(nodes: assignments))))
    }

    private func mockAssignment(id: String, isLocked: Bool = false, name: String, submission_types: [SubmissionType] = []) -> AssignmentPickerListResponse.Assignment {
        .init(name: name, _id: id, submissionTypes: submission_types, lockInfo: .init(isLocked: isLocked))
    }
}
