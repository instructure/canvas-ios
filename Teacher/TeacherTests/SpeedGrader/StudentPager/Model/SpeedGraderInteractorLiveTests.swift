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
import XCTest
import Combine
@testable import Teacher
import TestsFoundation

class SpeedGraderInteractorLiveTests: TeacherTestCase {
    private var testee: SpeedGraderInteractorLive!
    private let testData = (
        context: Context(.course, id: "1"),
        assignmentId: "1",
        userId: "1",
        inactiveUserId: "2",
        invalidUserId: "invalid",
        assignmentName: "test assignment",
        courseName: "test course",
        courseColor: UIColor.course1
    )

    override func setUp() {
        super.setUp()
        setupMocks()
        testee = SpeedGraderInteractorLive(
            context: testData.context,
            assignmentID: testData.assignmentId,
            userID: testData.userId,
            filter: [],
            env: environment
        )
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - Context Info

    func test_contextInfo_populates() {
        XCTAssertEqual(testee.contextInfo.value, nil)

        // WHEN
        testee.load()

        // THEN
        let expectedContextInfo = SpeedGraderContextInfo(
            courseName: testData.courseName,
            courseColor: testData.courseColor,
            assignmentName: testData.assignmentName
        )
        // compactMap is to ignore the initial nil value
        let publisher = testee.contextInfo.compactMap { $0 }
        XCTAssertSingleOutputEquals(publisher, expectedContextInfo)
    }

    // MARK: - Data State

    func test_dataState() throws {
        XCTAssertEqual(testee.state.value, .loading)

        // WHEN
        testee.load()

        // THEN
        let publisher = testee.state.filter { $0 != .loading }
        XCTAssertSingleOutputEquals(publisher, .data)
        let receivedData = try XCTUnwrap(testee.data)
        XCTAssertEqual(receivedData.submissions.count, 1)
        XCTAssertEqual(receivedData.assignment.name, testData.assignmentName)
        XCTAssertEqual(receivedData.focusedSubmissionIndex, 0)
    }

    func test_dataState_gradingBased_sorting() throws {
        // Given
        let getEnrollments = GetEnrollments(context: testData.context)
        api.mock(getEnrollments, value: [
            .make(id: "1", course_id: "1", enrollment_state: .active, user_id: "1"),
            .make(id: "2", course_id: "1", enrollment_state: .active, user_id: "2"),
            .make(id: "3", course_id: "1", enrollment_state: .active, user_id: "3"),
            .make(id: "4", course_id: "1", enrollment_state: .active, user_id: "4"),
            .make(id: "5", course_id: "1", enrollment_state: .inactive, user_id: "5")
        ])

        let getSubmission = GetSubmissions(
            context: testData.context,
            assignmentID: testData.assignmentId
        )
        api.mock(getSubmission, value: [
            .make(id: "1", submission_history: [], submission_type: .online_upload, user_id: "1", workflow_state: .unsubmitted),
            .make(id: "2", submission_history: [], submission_type: .online_upload, user_id: "2", workflow_state: .pending_review),
            .make(id: "3", score: 98, submission_history: [], submission_type: .online_upload, user_id: "3", workflow_state: .graded),
            .make(id: "4", submission_history: [], submission_type: .online_upload, user_id: "4", workflow_state: .unsubmitted),
            .make(id: "5", submission_history: [], submission_type: .online_upload, user_id: "5")
        ])

        // When
        testee = SpeedGraderInteractorLive(
            context: testData.context,
            assignmentID: testData.assignmentId,
            userID: "1",
            filter: [],
            sortingUponGradingNeeds: true,
            env: environment
        )

        // Then
        XCTAssertEqual(testee.state.value, .loading)

        // WHEN
        testee.load()

        // THEN
        let publisher = testee.state.filter { $0 != .loading }
        XCTAssertSingleOutputEquals(publisher, .data)

        let receivedData = try XCTUnwrap(testee.data)
        XCTAssertEqual(receivedData.submissions.count, 4)
        XCTAssertEqual(receivedData.assignment.name, testData.assignmentName)
        XCTAssertEqual(receivedData.focusedSubmissionIndex, 1)

        let submissionsIDs = receivedData.submissions.map(\.id)
        XCTAssertEqual(submissionsIDs, ["2", "1", "4", "3"])
    }

    // MARK: - Error States

    func test_errorState_unexpectedError() {
        let getAssignment = GetAssignment(
            courseID: testData.context.id,
            assignmentID: testData.assignmentId,
            include: [.overrides]
        )
        api.mock(getAssignment, value: nil, error: NSError.internalError())
        XCTAssertEqual(testee.state.value, .loading)

        // WHEN
        testee.load()

        // THEN
        let publisher = testee.state.filter { $0 != .loading }
        XCTAssertSingleOutputEquals(publisher, .error(.unexpectedError(NSError.internalError())))
    }

    func test_errorState_noSubmissions() {
        let getSubmission = GetSubmissions(
            context: testData.context,
            assignmentID: testData.assignmentId
        )
        api.mock(getSubmission, value: [])
        XCTAssertEqual(testee.state.value, .loading)

        // WHEN
        testee.load()

        // THEN
        let publisher = testee.state.filter { $0 != .loading }
        XCTAssertSingleOutputEquals(publisher, .error(.submissionNotFound))
    }

    func test_errorState_userIdNotFound() {
        testee = SpeedGraderInteractorLive(
            context: testData.context,
            assignmentID: testData.assignmentId,
            userID: testData.invalidUserId,
            filter: [],
            env: environment
        )
        XCTAssertEqual(testee.state.value, .loading)

        // WHEN
        testee.load()

        // THEN
        let publisher = testee.state.filter { $0 != .loading }
        XCTAssertSingleOutputEquals(publisher, .error(.userIdNotFound))
    }

    private func setupMocks() {
        let getAssignment = GetAssignment(
            courseID: testData.context.id,
            assignmentID: testData.assignmentId,
            include: [.overrides]
        )
        api.mock(getAssignment, value: .make(name: testData.assignmentName))

        let getSubmission = GetSubmissions(
            context: testData.context,
            assignmentID: testData.assignmentId
        )
        api.mock(getSubmission, value: [
            .make(id: "1", submission_history: [], submission_type: .online_upload, user_id: testData.userId),
            .make(id: "2", submission_history: [], submission_type: .online_upload, user_id: testData.inactiveUserId)
        ])

        // User2 should be inactive
        let getEnrollments = GetEnrollments(context: testData.context)
        api.mock(getEnrollments, value: [
            .make(id: "1", course_id: "1", enrollment_state: .active, user_id: "1"),
            .make(id: "2", course_id: "1", enrollment_state: .inactive, user_id: "2")
        ])

        let getCourse = GetCourse(courseID: testData.context.id)
        api.mock(getCourse, value: .make(name: testData.courseName))

        let getColors = GetCustomColors()
        api.mock(getColors, value: .init(custom_colors: [
            testData.context.canvasContextID: testData.courseColor.variantForLightMode.hexString
        ]))
    }
}
