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

import Foundation
import XCTest
@testable import Core
@testable import CoreUITests
import TestsFoundation

class SubmissionCommentsTests: CoreUITestCase {
    lazy var course = mock(course: .make())

    lazy var assignment = mock(assignment: .make(
            submission_types: [ .online_upload ],
            allowed_extensions: [ "pdf" ]
    ))

    func testFileComments() {
        mockBaseRequests()
        let attachments = [
            APIFile.make(id: "1", display_name: "File 1"),
            APIFile.make(id: "2", display_name: "File 2"),
        ]
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            id: "1",
            user_id: "1",
            submission_type: .online_upload,
            attempt: 1,
            attachments: attachments,
            user: APISubmissionUser.make(id: "1", short_name: "Student")
        ))
        attachments.forEach { mockURL($0.url!.rawValue, data: nil) }

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()

        XCTAssertTrue(SubmissionComments.attemptCell(submissionID: "1", attempt: 1).isVisible)
        XCTAssertTrue(SubmissionComments.fileView(fileID: "1").isVisible)
        XCTAssertTrue(SubmissionComments.fileView(fileID: "2").isVisible)
    }

    func testAttemptComments() {
        mockBaseRequests()
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            id: "1",
            user_id: "1",
            submission_type: .online_quiz,
            attempt: 1,
            user: APISubmissionUser.make(id: "1", short_name: "Student")
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()

        XCTAssertTrue(SubmissionComments.attemptCell(submissionID: "1", attempt: 1).isVisible)
        XCTAssertTrue(SubmissionComments.attemptView(attempt: 1).isVisible)
    }

    func testTextComments() {
        mockBaseRequests()
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            id: "1",
            user_id: "1",
            submission_type: .online_upload,
            attempt: 1,
            attachments: [],
            submission_comments: [
                APISubmissionComment.make(
                    id: "1",
                    author_id: "2",
                    author: APISubmissionCommentAuthor.make(display_name: "Teacher"),
                    comment: "This document is completely empty"
                ),
                APISubmissionComment.make(
                    id: "2",
                    author_id: "1",
                    author: APISubmissionCommentAuthor.make(display_name: "Student"),
                    comment: "Oops, I meant a different file"
                ),
            ]
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()

        XCTAssertTrue(SubmissionComments.textCell(commentID: "1").isVisible)
        XCTAssertTrue(SubmissionComments.textCell(commentID: "2").isVisible)
    }

    func testCreateTextComment() {
        mockBaseRequests()
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make())

        logIn()
        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()
        SubmissionDetails.drawerGripper.tap() // Make it full height.

        XCTAssertFalse(SubmissionComments.addCommentButton.isEnabled)
        SubmissionComments.commentTextView.tap()
        SubmissionComments.commentTextView.typeText("First!")
        XCTAssertTrue(SubmissionComments.addCommentButton.isEnabled)

        mockData(PutSubmissionGradeRequest(courseID: course.id.value, assignmentID: assignment.id.value, userID: "1", body: nil), value: APISubmission.make(
            submission_comments: [ APISubmissionComment.make(
                id: "42",
                author_id: "1",
                author: APISubmissionCommentAuthor.make(display_name: "Student"),
                comment: "First!"
            ), ]
        ))
        SubmissionComments.addCommentButton.tap()
        XCTAssertTrue(SubmissionComments.textCell(commentID: "42").isVisible)
    }

    func testAudioComments() {
        mockBaseRequests()
        let testm4a = Bundle(for: SubmissionCommentsTests.self).url(forResource: "test", withExtension: "m4a")!
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            id: "1",
            user_id: "1",
            submission_type: .online_upload,
            attempt: 1,
            attachments: [],
            submission_comments: [
                APISubmissionComment.make(
                    id: "1",
                    author_id: "2",
                    author: APISubmissionCommentAuthor.make(display_name: "Teacher"),
                    media_comment: APISubmissionCommentMedia.make(
                        url: testm4a,
                        media_type: .audio
                    )
                ),
                APISubmissionComment.make(
                    id: "2",
                    author_id: "1",
                    author: APISubmissionCommentAuthor.make(display_name: "Student"),
                    media_comment: APISubmissionCommentMedia.make(
                        url: testm4a,
                        media_type: .audio
                    )
                ),
            ]
        ))
        mockURL(testm4a, data: try! Data(contentsOf: testm4a))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()

        XCTAssertTrue(SubmissionComments.audioCell(commentID: "1").isVisible)
        XCTAssertTrue(SubmissionComments.audioCell(commentID: "2").isVisible)
        SubmissionComments.audioCellPlayPauseButton(commentID: "1").tap()
        SubmissionComments.audioCellPlayPauseButton(commentID: "2").tap()
    }

    func xtestAudioRecording() {
        mockBaseRequests()
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make())
        mockData(GetMediaServiceRequest(), value: APIMediaService(domain: "canvas.instructure.com"))
        mockData(PostMediaSessionRequest(), value: APIMediaSession(ks: "k"))
        mockEncodedData(PostMediaUploadTokenRequest(body: .init(ks: "k")), data: "<id>t</id>".data(using: .utf8))
        mockData(PostMediaUploadRequest(fileURL: URL(string: "data:text/plain,")!, type: .audio, ks: "k", token: "t"))
        mockEncodedData(PostMediaIDRequest(ks: "k", token: "t", type: .audio), data: "<id>2</id>".data(using: .utf8))
        mockData(PutSubmissionGradeRequest(
            courseID: course.id.value,
            assignmentID: assignment.id.value,
            userID: "1",
            body: nil
        ), value: APISubmission.make(
            submission_comments: [ APISubmissionComment.make(
                id: "42",
                media_comment: APISubmissionCommentMedia.make(
                    url: URL(string: "data:audio/x-m4a,")!,
                    media_id: "23",
                    media_type: .audio
                )
            ), ]
        ))

        logIn()
        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()

        SubmissionComments.addMediaButton.tap()

        allowAccessToMicrophone {
            app.find(label: "Record Audio").tap()
        }
        AudioRecorder.recordButton.tap()
        AudioRecorder.stopButton.tap()
        XCTAssertTrue(AudioRecorder.currentTimeLabel.isVisible)
        AudioRecorder.clearButton.tap()
        AudioRecorder.cancelButton.tap()
        AudioRecorder.cancelButton.waitToVanish()

        SubmissionComments.addMediaButton.tap()
        app.find(label: "Record Audio").tap()
        AudioRecorder.recordButton.tap()
        AudioRecorder.stopButton.tap()
        XCTAssertTrue(AudioRecorder.currentTimeLabel.isVisible)
        AudioRecorder.sendButton.tap()
        XCTAssertTrue(SubmissionComments.audioCell(commentID: "42").waitToExist().isVisible)
    }
}
