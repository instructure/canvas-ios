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

<<<<<<<< HEAD:Teacher/TeacherTests/SpeedGrader/MainLayout/View/SubmissionHeaderViewTests.swift
class SubmissionHeaderViewModelTests: TeacherTestCase {
========
class SpeedGraderPageHeaderViewModelTests: TeacherTestCase {
>>>>>>>> origin/master:Teacher/TeacherTests/SpeedGrader/MainLayout/ViewModel/SpeedGraderPageHeaderViewModelTests.swift

    func testGroupSubmissionCheck() {
        let submission = Submission(context: databaseClient)
        let assignment = Assignment(context: databaseClient)
<<<<<<<< HEAD:Teacher/TeacherTests/SpeedGrader/MainLayout/View/SubmissionHeaderViewTests.swift
        let testee = SubmissionHeaderView(
            assignment: assignment,
            submission: submission,
            isLandscapeLayout: false,
            landscapeSplitLayoutViewModel: SpeedGraderLandscapeSplitLayoutViewModel()
        )

        assignment.gradedIndividually = false
        submission.groupID = "TestGroupID"

        let testee = SubmissionHeaderViewModel(
========
        assignment.gradedIndividually = false
        submission.groupID = "TestGroupID"

        let testee = SpeedGraderPageHeaderViewModel(
>>>>>>>> origin/master:Teacher/TeacherTests/SpeedGrader/MainLayout/ViewModel/SpeedGraderPageHeaderViewModelTests.swift
            assignment: assignment,
            submission: submission,
        )

<<<<<<<< HEAD:Teacher/TeacherTests/SpeedGrader/MainLayout/View/SubmissionHeaderViewTests.swift
        XCTAssertTrue(testee.isGroupSubmission)
========
        XCTAssertTrue(testee.userNameModel.isGroup)
>>>>>>>> origin/master:Teacher/TeacherTests/SpeedGrader/MainLayout/ViewModel/SpeedGraderPageHeaderViewModelTests.swift
    }

    func testGroupName() {
        let submission = Submission(context: databaseClient)
        let assignment = Assignment(context: databaseClient)
<<<<<<<< HEAD:Teacher/TeacherTests/SpeedGrader/MainLayout/View/SubmissionHeaderViewTests.swift
        let testee = SubmissionHeaderView(
            assignment: assignment,
            submission: submission,
            isLandscapeLayout: false,
            landscapeSplitLayoutViewModel: SpeedGraderLandscapeSplitLayoutViewModel()
        )

        assignment.gradedIndividually = false
        submission.groupName = "TestGroup Name"

        var testee = SubmissionHeaderViewModel(
            assignment: assignment,
            submission: submission,
        )
        XCTAssertEqual(testee.groupName, nil)

        submission.groupID = "TestGroupID"

        testee = SubmissionHeaderViewModel(
========
        assignment.gradedIndividually = false
        submission.groupName = "TestGroup Name"

        var testee = SpeedGraderPageHeaderViewModel(
            assignment: assignment,
            submission: submission,
        )
        XCTAssertEqual(testee.userNameModel.name, "Student")

        submission.groupID = "TestGroupID"

        testee = SpeedGraderPageHeaderViewModel(
>>>>>>>> origin/master:Teacher/TeacherTests/SpeedGrader/MainLayout/ViewModel/SpeedGraderPageHeaderViewModelTests.swift
            assignment: assignment,
            submission: submission,
        )

<<<<<<<< HEAD:Teacher/TeacherTests/SpeedGrader/MainLayout/View/SubmissionHeaderViewTests.swift
        XCTAssertEqual(testee.groupName, "TestGroup Name")
========
        XCTAssertEqual(testee.userNameModel.name, "TestGroup Name")
>>>>>>>> origin/master:Teacher/TeacherTests/SpeedGrader/MainLayout/ViewModel/SpeedGraderPageHeaderViewModelTests.swift
    }

    func testRouteToGroupSubmitter() {
        let submission = Submission(context: databaseClient)
        let assignment = Assignment(context: databaseClient)
<<<<<<<< HEAD:Teacher/TeacherTests/SpeedGrader/MainLayout/View/SubmissionHeaderViewTests.swift
        let testee = SubmissionHeaderView(
            assignment: assignment,
            submission: submission,
            isLandscapeLayout: false,
            landscapeSplitLayoutViewModel: SpeedGraderLandscapeSplitLayoutViewModel()
        )

========
>>>>>>>> origin/master:Teacher/TeacherTests/SpeedGrader/MainLayout/ViewModel/SpeedGraderPageHeaderViewModelTests.swift
        assignment.gradedIndividually = false
        assignment.courseID = "testCourseID"
        submission.userID = "testUserID"
        submission.groupID = "TestGroupID"

<<<<<<<< HEAD:Teacher/TeacherTests/SpeedGrader/MainLayout/View/SubmissionHeaderViewTests.swift
        let testee = SubmissionHeaderViewModel(
========
        let testee = SpeedGraderPageHeaderViewModel(
>>>>>>>> origin/master:Teacher/TeacherTests/SpeedGrader/MainLayout/ViewModel/SpeedGraderPageHeaderViewModelTests.swift
            assignment: assignment,
            submission: submission,
        )

        XCTAssertNil(testee.routeToSubmitter)
    }

    func testRouteToIndividialInGroupSubmission() {
        let submission = Submission(context: databaseClient)
        let assignment = Assignment(context: databaseClient)
<<<<<<<< HEAD:Teacher/TeacherTests/SpeedGrader/MainLayout/View/SubmissionHeaderViewTests.swift
        let testee = SubmissionHeaderView(
            assignment: assignment,
            submission: submission,
            isLandscapeLayout: false,
            landscapeSplitLayoutViewModel: SpeedGraderLandscapeSplitLayoutViewModel()
        )

========
>>>>>>>> origin/master:Teacher/TeacherTests/SpeedGrader/MainLayout/ViewModel/SpeedGraderPageHeaderViewModelTests.swift
        assignment.gradedIndividually = true
        assignment.courseID = "testCourseID"
        submission.userID = "testUserID"
        submission.groupID = "TestGroupID"

<<<<<<<< HEAD:Teacher/TeacherTests/SpeedGrader/MainLayout/View/SubmissionHeaderViewTests.swift
        let testee = SubmissionHeaderViewModel(
========
        let testee = SpeedGraderPageHeaderViewModel(
>>>>>>>> origin/master:Teacher/TeacherTests/SpeedGrader/MainLayout/ViewModel/SpeedGraderPageHeaderViewModelTests.swift
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

        let testee = SpeedGraderPageHeaderViewModel(
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
