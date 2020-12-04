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

class SpeedGraderCommentUITests: MiniCanvasUITestCase {
    lazy var student = mocked.students.first!
    lazy var submission = firstAssignment.submission(byUserId: student.id.value)!

    func showSubmission() {
        show("/courses/\(firstCourse.id)/assignments/\(firstAssignment.id)/submissions/\(student.id.value)", options: .modal(.fullScreen))
    }

    func testSubmissionCommentAttachments() {
        let attachment = APIFile.make(
            id: "1",
            display_name: "screenshot.png",
            url: UIImage.paperclipLine.asDataUrl!
        )
        submission.api.submission_comments = [ .make(attachments: [attachment]) ]

        showSubmission()
        SpeedGrader.Segment.comments.tap()
        SubmissionComments.fileView(fileID: "1").tap()
        FileDetails.imageView.waitToExist()
        NavBar.dismissButton.tap()
        FileDetails.imageView.waitToVanish()
    }

    func testDisplayStudentAndTeacherComments() {
        let teacher = mocked.teachers.first!
        let teacherComment = APISubmissionComment.make(
            id: mocked.nextId().value,
            author_id: teacher.id,
            author_name: teacher.name,
            author: .make(from: teacher),
            comment: "Completely incorrect"
        )
        let studentComment = APISubmissionComment.make(
            id: mocked.nextId().value,
            author_id: student.id,
            author_name: student.name,
            author: .make(from: student),
            comment: "no u"
        )
        submission.api.submission_comments = [teacherComment, studentComment]

        showSubmission()
        SpeedGrader.Segment.comments.tap()

        XCTAssertEqual(
            SubmissionComments.textCell(commentID: teacherComment.id).label(),
            teacherComment.comment
        )
        XCTAssertEqual(
            SubmissionComments.textCell(commentID: studentComment.id).label(),
            studentComment.comment
        )
    }

    func testNewTextComment() {
        let testString = "Is this thing on?"

        showSubmission()
        SpeedGrader.Segment.comments.tap()
        SubmissionComments.commentTextView.pasteText(testString)

        XCTAssert((submission.api.submission_comments ?? []).isEmpty)
        SubmissionComments.addCommentButton.tap()

        XCTAssertEqual(app.find(idStartingWith: "SubmissionComments.textCell.").label(), testString)
        waitUntil { submission.api.submission_comments?.isEmpty == false }
    }

    func testNewAudioComment() throws {
        try XCTSkipIf(true, "recordButton.tap() doesn't start recording on bitrise")
        showSubmission()
        SpeedGrader.Segment.comments.tap()
        SubmissionComments.addMediaButton.tapUntil {
            app.find(label: "Record Audio").exists
        }
        allowAccessToMicrophone {
            app.find(label: "Record Audio").tap()
        }
        AudioRecorder.recordButton.tap()
        AudioRecorder.stopButton.tap()
        AudioRecorder.sendButton.tap()

        XCTAssertTrue(app.find(idStartingWith: "SubmissionComments.audioCell").waitToExist().isVisible)
    }
}
