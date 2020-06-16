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

class SpeedGraderCommentUITests: MiniCanvasUITestCase {
    lazy var student = mocked.students.first!
    lazy var submission = firstAssignment.submission(byUserId: student.id.value)!

    func showSubmission() {
        show("/courses/\(firstCourse.id)/assignments/\(firstAssignment.id)/submissions/\(submission.api.id)")
        SpeedGrader.dismissTutorial()
    }

    func testSubmissionCommentAttachments() {
        let attachment = APIFile.make(
            id: "1",
            display_name: "screenshot.png",
            url: UIImage.icon(.paperclip).asDataUrl!
        )
        submission.api.submission_comments = [ .make(attachments: [attachment]) ]

        showSubmission()
        SpeedGrader.segmentButton(label: "Comments").tap()
        app.find(id: "CommentAttachment-1").tap()
        app.find(id: "AttachmentView.image").waitToExist()
        app.find(id: "attachment-view.share-btn").waitToExist()
        app.find(label: "Attachment").waitToExist()
        NavBar.dismissButton.tap()
        app.find(id: "AttachmentView.image").waitToVanish()
    }

    func testDisplayStudentAndTeacherComments() {
        let teacher = mocked.teachers.first!
        let teacherComment = APISubmissionComment.make(
            id: mocked.nextId().value,
            author_id: teacher.id.value,
            author_name: teacher.name,
            author: .make(from: teacher),
            comment: "Completely incorrect"
        )
        let studentComment = APISubmissionComment.make(
            id: mocked.nextId().value,
            author_id: student.id.value,
            author_name: student.name,
            author: .make(from: student),
            comment: "no u"
        )
        submission.api.submission_comments = [teacherComment, studentComment]

        showSubmission()
        SpeedGrader.segmentButton(label: "Comments").tap()

        XCTAssertEqual(
            SubmissionComments.textCell(commentID: "comment-\(teacherComment.id)").label(),
            teacherComment.comment
        )
        XCTAssertEqual(
            SubmissionComments.textCell(commentID: "comment-\(studentComment.id)").label(),
            studentComment.comment
        )
    }

    func testNewTextComment() {
        let testString = "Is this thing on?"

        showSubmission()
        SpeedGrader.segmentButton(label: "Comments").tap()
        SubmissionComments.commentTextView.typeText(testString)

        XCTAssert((submission.api.submission_comments ?? []).isEmpty)
        SubmissionComments.addCommentButton.tap()

        XCTAssertEqual(app.find(idStartingWith: "SubmissionComments.textCell.").label(), testString)
        waitUntil { submission.api.submission_comments?.isEmpty == false }
    }

    func testNewAudioComment() {
        showSubmission()
        SpeedGrader.segmentButton(label: "Comments").tap()
        SubmissionComments.addMediaButton.tap()
        allowAccessToMicrophone {
            app.find(label: "Record Audio").tap()
        }
        AudioRecorder.recordButton.tap()
        AudioRecorder.stopButton.tap()
        AudioRecorder.sendButton.tap()

        XCTAssertTrue(app.find(id: "audio-comment.label").waitToExist().isVisible)
    }
}
