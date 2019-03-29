//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import XCTest
@testable import Core
import TestsFoundation

class SubmissionCommentsTests: StudentTest {
    lazy var course: APICourse = {
        let course = APICourse.make()
        mockData(GetCourseRequest(courseID: course.id), value: course)
        return course
    }()

    lazy var assignment: APIAssignment = {
        let assignment = APIAssignment.make([
            "submission_types": [ "online_upload" ],
            "allowed_extensions": [ "pdf" ],
        ])
        mockData(GetAssignmentRequest(courseID: course.id, assignmentID: assignment.id.value, include: []), value: assignment)
        return assignment
    }()

    func testCommentsList() {
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make([
            "id": "1",
            "attempt": 1,
            "user_id": "1",
            "submission_type": "online_upload",
            "attachments": [
                APIFile.fixture([ "id": "1", "display_name": "File 1" ]),
                APIFile.fixture([ "id": "2", "display_name": "File 2" ]),
            ],
            "submission_comments": [
                APISubmissionComment.fixture([
                    "id": "1",
                    "comment": "This document is completely empty",
                    "author_id": "2",
                    "author": APISubmissionCommentAuthor.fixture([ "display_name": "Teacher" ]),
                ]),
                APISubmissionComment.fixture([
                    "id": "2",
                    "comment": "Oops, I meant a different file",
                    "author_id": "1",
                    "author": APISubmissionCommentAuthor.fixture([ "display_name": "Student" ]),
                ]),
            ],
        ]))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetailsElement.drawerFilesButton.tap()
        SubmissionDetailsElement.drawerCommentsButton.tap()

        XCTAssertTrue(SubmissionComments.textCell(commentID: "1").isVisible)
        XCTAssertTrue(SubmissionComments.textCell(commentID: "2").isVisible)
    }

    func testAudioRecording() {
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make())
        mockData(GetMediaServiceRequest(), value: APIMediaService(domain: "canvas.instructure.com"))
        mockData(PostMediaSessionRequest(), value: APIMediaSession(ks: "k"))
        mockEncodedData(PostMediaUploadTokenRequest(body: .init(ks: "k")), data: "<id>t</id>".data(using: .utf8))
        mockData(PostMediaUploadRequest(fileURL: URL(string: "data:text/plain,")!, type: .audio, ks: "k", token: "t"))
        mockEncodedData(PostMediaIDRequest(ks: "k", token: "t", type: .audio), data: "<id>2</id>".data(using: .utf8))
        mockData(PutSubmissionGradeRequest(
            courseID: course.id,
            assignmentID: assignment.id.value,
            userID: "1",
            body: nil
        ), value: APISubmission.make([
            "submission_comments": [ APISubmissionComment.fixture([
                "id": "42",
                "media_comment": [
                    "url": "data:audio/x-m4a,",
                    "media_id": "23",
                    "media_type": "audio",
                ],
            ]), ],
        ]))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetailsElement.drawerFilesButton.tap()
        SubmissionDetailsElement.drawerCommentsButton.tap()

        SubmissionComments.addMediaButton.tap()
        Alert.button(label: "Record Audio").tap()
        allowAccessToMicrophone() // Need to manually grant access in simulator once.
        AudioRecorder.recordButton.tap()
        AudioRecorder.stopButton.tap()
        XCTAssertTrue(AudioRecorder.currentTimeLabel.isVisible)
        AudioRecorder.clearButton.tap()
        AudioRecorder.cancelButton.tap()
        XCTAssertFalse(AudioRecorder.cancelButton.isVisible)

        SubmissionComments.addMediaButton.tap()
        Alert.button(label: "Record Audio").tap()
        allowAccessToMicrophone()
        AudioRecorder.recordButton.tap()
        AudioRecorder.stopButton.tap()
        XCTAssertTrue(AudioRecorder.currentTimeLabel.isVisible)
        AudioRecorder.sendButton.tap()
        XCTAssertTrue(SubmissionComments.audioCell(commentID: "42").isVisible)
    }
}
