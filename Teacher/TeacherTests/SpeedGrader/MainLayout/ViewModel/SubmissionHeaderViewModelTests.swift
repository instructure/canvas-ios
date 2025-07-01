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

import Core
@testable import Teacher
import TestsFoundation
import XCTest

class SubmissionHeaderViewModelTests: TeacherTestCase {

    func testGroupSubmissionCheck() {
        let submission = Submission(context: databaseClient)
        let assignment = Assignment(context: databaseClient)
        assignment.gradedIndividually = false
        submission.groupID = "TestGroupID"

        let testee = SubmissionHeaderViewModel(
            assignment: assignment,
            submission: submission,
        )

        XCTAssertTrue(testee.userNameModel.isGroup)
    }

    func testGroupName() {
        let submission = Submission(context: databaseClient)
        let assignment = Assignment(context: databaseClient)
        assignment.gradedIndividually = false
        submission.groupName = "TestGroup Name"

        var testee = SubmissionHeaderViewModel(
            assignment: assignment,
            submission: submission,
        )
        XCTAssertEqual(testee.userNameModel.name, "Student")

        submission.groupID = "TestGroupID"

        testee = SubmissionHeaderViewModel(
            assignment: assignment,
            submission: submission,
        )

        XCTAssertEqual(testee.userNameModel.name, "TestGroup Name")
    }

    func testRouteToGroupSubmitter() {
        let submission = Submission(context: databaseClient)
        let assignment = Assignment(context: databaseClient)
        assignment.gradedIndividually = false
        assignment.courseID = "testCourseID"
        submission.userID = "testUserID"
        submission.groupID = "TestGroupID"

        let testee = SubmissionHeaderViewModel(
            assignment: assignment,
            submission: submission,
        )

        XCTAssertNil(testee.routeToSubmitter)
    }

    func testRouteToIndividialInGroupSubmission() {
        let submission = Submission(context: databaseClient)
        let assignment = Assignment(context: databaseClient)
        assignment.gradedIndividually = true
        assignment.courseID = "testCourseID"
        submission.userID = "testUserID"
        submission.groupID = "TestGroupID"

        let testee = SubmissionHeaderViewModel(
            assignment: assignment,
            submission: submission,
        )

        XCTAssertEqual(testee.routeToSubmitter, "/courses/testCourseID/users/testUserID")
    }

    func testSubmissionStatusUpdatesOnCoreDataChange() throws {
        let submission = Submission.save(.make(attempt: 1), in: databaseClient)
        let assignment = Assignment.save(.make(), in: databaseClient, updateSubmission: false, updateScoreStatistics: false)
        submission.submittedAt = Clock.now
        submission.excused = false
        try databaseClient.save()

        let testee = SubmissionHeaderViewModel(
            assignment: assignment,
            submission: submission
        )

        XCTAssertEqual(testee.submissionStatus, .submitted)

        // WHEN
        submission.excused = true
        try databaseClient.save()

        // THEN
        waitUntil(shouldFail: true) {
            testee.submissionStatus == .excused
        }
    }
}
