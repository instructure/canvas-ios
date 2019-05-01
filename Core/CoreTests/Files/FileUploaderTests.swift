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
import TestsFoundation
@testable import Core
import XCTest

class FileUploaderTests: CoreTestCase {
    class MockURLSession: URLSession {
        var finishedAndInvalidated = false
        override func finishTasksAndInvalidate() {
            finishedAndInvalidated = true
        }

        var tasks: [URLSessionTask] = []
        override func getAllTasks(completionHandler: @escaping ([URLSessionTask]) -> Void) {
            completionHandler(tasks)
        }
    }

    let session = MockURLSession()
    var fileUploader: UploadFile!
    let user = KeychainEntry(
        accessToken: "1",
        baseURL: URL(string: "https://canvas.instructure.com")!,
        expiresAt: nil,
        locale: nil,
        refreshToken: nil,
        userID: "1",
        userName: "user"
    )
    let courseID = "1"
    let assignmentID = "2"

    var onUpdate: (() -> Void)?

    lazy var files: Store<LocalUseCase<File>> = { [weak self] in
        return environment.subscribe(scope: .all(orderBy: #keyPath(File.id))) {
            self?.onUpdate?()
        }
    }()

    var file: File? {
        return files.first
    }

    override func setUp() {
        super.setUp()
        environment.currentSession = user
        fileUploader = UploadFile(bundleID: "core-tests", appGroup: nil, environment: environment)
        fileUploader.backgroundAPI = api
        files.refresh()
    }

    private func mockSubmission() {
        let submission = CreateSubmissionRequest.Body.Submission(
            text_comment: nil,
            submission_type: .online_upload,
            body: nil,
            url: nil,
            file_ids: nil,
            media_comment_id: nil,
            media_comment_type: nil
        )
        let submissionRequest = CreateSubmissionRequest(
            context: ContextModel(.course, id: courseID),
            assignmentID: assignmentID,
            body: .init(submission: submission)
        )
        api.mock(submissionRequest, value: APISubmission.make(), response: nil, error: nil)
    }

    func testSubmissionFlow() {
        let url = Bundle.main.url(forResource: "Info", withExtension: "plist")!
        databaseClient.performAndWait {
            let file = File.make()
            file.id = nil
            file.taskID = nil
            file.localFileURL = url
            file.prepareForSubmission(courseID: courseID, assignmentID: assignmentID)
            try! databaseClient.save()
        }

        let context = FileUploadContext.submission(courseID: "1", assignmentID: "2")
        let body = PostFileUploadTargetRequest.Body(name: url.lastPathComponent, on_duplicate: .rename, parent_folder_id: nil, size: url.lookupFileSize())
        let request = PostFileUploadTargetRequest(context: context, body: body)
        api.mock(request, value: FileUploadTarget.make(), response: nil, error: nil)
        let started = XCTestExpectation(description: "started upload")
        fileUploader.upload(file!, context: context) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            started.fulfill()
        }
        wait(for: [started], timeout: 0.1)
        let task = MockAPITask(taskIdentifier: 1)

        // send data
        let sent = XCTestExpectation(description: "sent data")
        onUpdate = {
            if self.file?.bytesSent == 1 {
                sent.fulfill()
            }
        }
        fileUploader.urlSession(session, task: task, didSendBodyData: 0, totalBytesSent: 1, totalBytesExpectedToSend: 10)
        wait(for: [sent], timeout: 0.1)

        // receive data
        let response = APIFile.make(["id": "45"])
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try! encoder.encode(response)
        let received = XCTestExpectation(description: "received data")
        onUpdate = {
            if self.file?.id == response.id.value {
                received.fulfill()
            }
        }
        fileUploader.urlSession(session, dataTask: task, didReceive: data)
        wait(for: [received], timeout: 0.1)

        // completed and submitted
        mockSubmission()
        XCTAssertNotNil(file?.taskID)
        XCTAssertNotNil(file?.assignmentID)
        let completed = XCTestExpectation(description: "task completed")
        let submitted = XCTestExpectation(description: "submitted")
        onUpdate = {
            if self.file?.taskID == nil {
                completed.fulfill()
            }
            if self.file?.assignmentID == nil {
                submitted.fulfill()
            }
        }
        fileUploader.urlSession(session, task: task, didCompleteWithError: nil)
        wait(for: [completed, submitted], timeout: 0.1)
    }

    func testCancel() {
        let session = MockURLSession()
        let task = MockAPITask(taskIdentifier: 1)
        session.tasks = [task]
        fileUploader.backgroundSession = session
        let file = File.make()
        file.taskID = 1
        fileUploader.cancel(file)
        XCTAssertEqual(task.cancelCount, 1)
    }

    func testInitIdentifier() {
        Keychain.addEntry(user)
        let session = UploadFile.Session(bundleID: "core-tests", appGroup: nil, userID: user.userID, baseURL: user.baseURL, actAsUserID: user.actAsUserID)
        let identifier = session.identifier
        let uploader = UploadFile(backgroundSessionIdentifier: identifier)
        XCTAssertNotNil(uploader)
    }

    func testSendsSubmittedNotification() {
        mockSubmission()
        let notifications = MockNotificationManager()
        fileUploader.notificationManager = notifications
        let task = MockAPITask(taskIdentifier: 1)
        File.make(["taskIDRaw": task.taskIdentifier, "assignmentID": assignmentID, "courseID": courseID])
        let expectation = XCTestExpectation(description: "notification sent")
        onUpdate = {
            if !notifications.mock.requests.isEmpty {
                expectation.fulfill()
            }
        }
        fileUploader.urlSession(session, task: task, didCompleteWithError: nil)
        wait(for: [expectation], timeout: 0.1)
        let notification = notifications.mock.requests.first
        XCTAssertEqual(notification?.content.title, "Assignment submitted!")
        XCTAssertEqual(notification?.route, Route("/courses/1/assignments/2"))
    }

    func testSendsFailedNotification() {
        let notifications = MockNotificationManager()
        fileUploader.notificationManager = notifications
        let task = MockAPITask(taskIdentifier: 1)
        File.make(["taskIDRaw": task.taskIdentifier, "assignmentID": assignmentID, "courseID": courseID])
        let expectation = XCTestExpectation(description: "notification sent")
        onUpdate = {
            if !notifications.mock.requests.isEmpty {
                expectation.fulfill()
            }
        }
        fileUploader.urlSession(session, task: task, didCompleteWithError: nil)
        wait(for: [expectation], timeout: 0.1)
        let notification = notifications.mock.requests.first
        XCTAssertEqual(notification?.content.title, "Assignment submission failed!")
        XCTAssertEqual(notification?.route, Route("/courses/1/assignments/2"))
    }

    func testURLSessionDidFinishEvents() {
        let expectation = XCTestExpectation(description: "completion handler was called")
        fileUploader.completionHandler = expectation.fulfill
        fileUploader.urlSessionDidFinishEvents(forBackgroundURLSession: session)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(session.finishedAndInvalidated)
    }
}
