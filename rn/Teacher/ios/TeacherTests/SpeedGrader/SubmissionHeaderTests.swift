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
import XCTest

class SubmissionHeaderTests: TeacherTestCase {

    func testGroupSubmissionCheck() {
        let submission = Submission(context: databaseClient)
        let assignment = Assignment(context: databaseClient)
        let testee = SubmissionHeader(assignment: assignment, submission: submission)

        assignment.gradedIndividually = false
        submission.groupID = "TestGroupID"

        XCTAssertTrue(testee.isGroupSubmission)
    }

    func testGroupName() {
        let submission = Submission(context: databaseClient)
        let assignment = Assignment(context: databaseClient)
        let testee = SubmissionHeader(assignment: assignment, submission: submission)

        assignment.gradedIndividually = false
        submission.groupName = "TestGroup Name"
        XCTAssertEqual(testee.groupName, nil)

        submission.groupID = "TestGroupID"
        XCTAssertEqual(testee.groupName, "TestGroup Name")
    }

    func testRouteToGroupSubmitter() {
        let submission = Submission(context: databaseClient)
        let assignment = Assignment(context: databaseClient)
        let testee = SubmissionHeader(assignment: assignment, submission: submission)

        assignment.gradedIndividually = false
        assignment.courseID = "testCourseID"
        submission.userID = "testUserID"
        submission.groupID = "TestGroupID"
        XCTAssertNil(testee.routeToSubmitter)
    }

    func testRouteToIndividialInGroupSubmission() {
        let submission = Submission(context: databaseClient)
        let assignment = Assignment(context: databaseClient)
        let testee = SubmissionHeader(assignment: assignment, submission: submission)

        assignment.gradedIndividually = true
        assignment.courseID = "testCourseID"
        submission.userID = "testUserID"
        submission.groupID = "TestGroupID"
        XCTAssertEqual(testee.routeToSubmitter, "/courses/testCourseID/users/testUserID")
    }
}
