//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import XCTest
import TestsFoundation
@testable import Core
@testable import CoreUITests

class SpeedGraderTests: MiniCanvasUITestCase {
    func testSubmissionCommentAttachments() {
        let attachment = APIFile.make(
            id: "1",
            display_name: "screenshot.png",
            url: UIImage.icon(.paperclip).asDataUrl!
        )
        let student = mocked.students.first!
        let submission = firstAssignment.submission(byUserId: student.id)!
        submission.api.submission_comments = [ .make(attachments: [attachment]) ]

        show("/courses/\(firstCourse.id)/assignments/\(firstAssignment.id)/submissions/\(submission.api.id)")
        SpeedGrader.dismissTutorial()
        app.find(id: "speedgrader.segment-control").waitToExist()
        app.segmentedControls.firstMatch.buttons["Comments"].tap()
        app.find(id: "CommentAttachment-1").tap()
        app.find(id: "AttachmentView.image").waitToExist()
        app.find(id: "attachment-view.share-btn").waitToExist()
        app.find(label: "Attachment").waitToExist()
        NavBar.dismissButton.tap()
        app.find(id: "AttachmentView.image").waitToVanish()
    }

    func testNavigateToSpeedGrader() {
        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.assignments.tap()
        AssignmentsList.assignment(id: firstAssignment.id).tap()
        AssignmentDetails.viewAllSubmissionsButton.tap()
        SubmissionsList.row(contextID: mocked.students[1].id.value).tap()
        SpeedGrader.dismissTutorial()
    }

    func testQuizLoadsWebView() {
        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.quizzes.tap()
        app.find(id: "quiz-row-0").tap()
        app.find(id: "quizzes.details.viewAllSubmissionsRow").tap()
        let student = mocked.students[1]
        SubmissionsList.row(contextID: student.id.value).tap()
        SpeedGrader.dismissTutorial()
        XCTAssertFalse(app.find(label: "A webview submission from \(student.name)").waitToExist().isOffscreen())
    }

    func testUpdateScores() {
        let quiz = firstCourse.quizzes[0]
        let student = mocked.students[0]
        let submission = quiz.submission(byUserId: student.id)!

        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.quizzes.tap()
        app.find(id: "quiz-row-0").tap()
        app.find(id: "quizzes.details.viewAllSubmissionsRow").tap()
        SubmissionsList.row(contextID: student.id.value).tap()
        app.segmentedControls.firstMatch.buttons["Grades"].tap()
        SpeedGrader.gradePickerButton.tap()
        app.textFields.firstElement.typeText("6")

        let expectation = MiniCanvasServer.shared.expectationFor(request: PutSubmissionGradeRequest(
            courseID: firstCourse.id,
            assignmentID: quiz.api.assignment_id!.value,
            userID: student.id
        ))
        app.buttons["OK"].tap()
        wait(for: [expectation], timeout: 3)

        XCTAssertEqual(submission.api.grade, "6")
    }
}
