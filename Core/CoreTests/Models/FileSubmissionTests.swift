//
// Copyright (C) 2018-present Instructure, Inc.
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

class FileSubmissionTests: CoreTestCase {
    func testFailedFalse() {
        let f = FileSubmission.make(["error": nil])
        XCTAssertFalse(f.failed)
    }

    func testFailedTrueWhenError() {
        let f = FileSubmission.make(["error": "some error"])
        XCTAssertTrue(f.failed)
    }

    func testFailedTrueWhenUploadError() {
        let f = FileSubmission.make(["error": nil])
        let upload = FileUpload.make(["error": "some error"])
        f.addToFileUploads(upload)
        XCTAssertTrue(f.failed)
    }

    func testReadyToSubmitTrueWhenNoError() {
        let f = FileSubmission.make(["error": nil])
        XCTAssertTrue(f.readyToSubmit)
    }

    func testReadyToSubmitTrueWhenAllUploadsCompleted() {
        let f = FileSubmission.make(["error": nil])
        let upload = FileUpload.make(["completed": true])
        f.addToFileUploads(upload)
        XCTAssertTrue(f.readyToSubmit)
    }

    func testReadyToSubmitFalseWhenUploadNotComplete() {
        let f = FileSubmission.make(["error": nil])
        let upload = FileUpload.make(["completed": false])
        f.addToFileUploads(upload)
        XCTAssertFalse(f.readyToSubmit)
    }

    func testNext() {
        let submission = FileSubmission.make()
        let expected = FileUpload.make([
            "error": nil,
            "completed": false,
            "taskIDRaw": nil,
        ])
        let one = FileUpload.make(["completed": true])
        let two = FileUpload.make(["taskIDRaw": 1])
        submission.addToFileUploads(one)
        submission.addToFileUploads(two)
        submission.addToFileUploads(expected)

        let next = submission.next

        XCTAssertEqual(next, expected)
    }

    func testInProgressTrue() {
        let submission = FileSubmission.make()
        submission.started = true
        submission.submitted = false
        submission.error = nil
        XCTAssertTrue(submission.inProgress)
    }

    func testInProgressFalseWhenNotStarted() {
        let submission = FileSubmission.make()
        submission.started = false
        submission.submitted = false
        submission.error = nil

        XCTAssertFalse(submission.inProgress)
    }

    func testInProgressFalseWhenSubmitted() {
        let submission = FileSubmission.make()
        submission.started = true
        submission.submitted = true
        submission.error = nil

        XCTAssertFalse(submission.inProgress)
    }

    func testInProgressFalseWhenError() {
        let submission = FileSubmission.make()
        submission.started = true
        submission.submitted = false
        submission.error = "error"

        XCTAssertFalse(submission.inProgress)
    }

    func testSendFailedNotification() {
        FileSubmission.sendFailedNotification(courseID: "1", assignmentID: "2", manager: notificationManager)
        let request = notificationCenter.requests.last
        XCTAssertEqual(request?.content.title, "Assignment submission failed!")
        XCTAssertEqual(request?.content.body, "Something went wrong with an assignment submission.")
        XCTAssertEqual(request?.content.userInfo[NotificationManager.RouteURLKey] as? String, "/courses/1/assignments/2")
    }

    func testSendCompletedNotification() {
        FileSubmission.sendCompletedNotification(courseID: "1", assignmentID: "2", manager: notificationManager)
        let request = notificationCenter.requests.last
        XCTAssertEqual(request?.content.title, "Assignment submitted!")
        XCTAssertEqual(request?.content.body, "Your files were uploaded and the assignment was submitted successfully.")
        XCTAssertEqual(request?.content.userInfo[NotificationManager.RouteURLKey] as? String, "/courses/1/assignments/2")
    }
}
