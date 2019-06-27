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
import CoreData

class UploadManagerTests: CoreTestCase {
    let url = URL(fileURLWithPath: "/image.jpg")
    let uploadContext: FileUploadContext = .course("1")
    let backgroundSession = MockURLSession()
    let manager = UploadManager()
    var context: NSManagedObjectContext {
        return NSPersistentContainer.shared.viewContext
    }

    override func setUp() {
        super.setUp()

        manager.notificationManager = notificationManager
        URLSessionAPI.delegateURLSession = { _, _ in self.backgroundSession }
    }

    func testAddAndSubscribe() {
        let expectation = XCTestExpectation(description: "subscribe event")
        let store = manager.subscribe(batchID: "1") {
            expectation.fulfill()
        }
        manager.add(url: URL(fileURLWithPath: "/image.png"), batchID: "1")
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(store.count, 1)
    }

    func testSubscribeScopedToBatchAndUser() {
        let good = context.insert() as File
        good.displayName = "Good subscribe file"
        good.batchID = "1"
        good.user = File.User(id: currentSession.userID, baseURL: currentSession.baseURL, actAsUserID: currentSession.actAsUserID)
        let badBatch = context.insert() as File
        badBatch.batchID = "2"
        badBatch.user = good.user
        let badUser = context.insert() as File
        badUser.batchID = good.batchID
        badUser.user = File.User(id: "bad", baseURL: currentSession.baseURL, actAsUserID: currentSession.actAsUserID)
        try! context.save()
        let store = manager.subscribe(batchID: good.batchID!) {}
        XCTAssertEqual(store.count, 1)
        XCTAssertEqual(store.first, good)
    }

    func testUploadBatch() {
        mockTarget(name: url.lastPathComponent, size: 0, context: uploadContext)
        manager.add(url: url, batchID: "1")
        manager.upload(batch: "1", to: uploadContext)
        let task = MockURLSession.dataMocks.first { $0.value.taskIdentifier == 0 }?.value
        XCTAssertNotNil(task)
        XCTAssertEqual(task?.uploadStep, .target)
        XCTAssertEqual(task?.resumed, true)
    }

    func testUploadURL() {
        mockTarget(name: url.lastPathComponent, size: 0, context: uploadContext)
        manager.upload(url: url, to: uploadContext)
        let task = MockURLSession.dataMocks.first { $0.value.taskIdentifier == 0 }?.value
        XCTAssertNotNil(task)
        XCTAssertEqual(task?.uploadStep, .target)
        XCTAssertEqual(task?.resumed, true)
    }

    func testUploadFile() throws {
        mockTarget(name: url.lastPathComponent, size: 0, context: uploadContext)
        let file = context.insert() as File
        file.localFileURL = url
        try context.save()
        manager.upload(file: file, to: .course("1"))
        let task = MockURLSession.dataMocks.first { $0.value.taskIdentifier == 0 }?.value
        XCTAssertNotNil(task)
        XCTAssertEqual(task?.uploadStep, .target)
        XCTAssertEqual(task?.resumed, true)
        context.refresh(file, mergeChanges: false)
        XCTAssertEqual(file.taskID, task?.taskIdentifier)
    }

    func testSessionDataTaskDidReceiveDataTarget() throws {
        let file = context.insert() as File
        file.localFileURL = url
        file.taskID = 0
        try context.save()
        let task = MockURLSession.MockDataTask()
        task.uploadStep = .target
        task.taskIdentifier = 0
        let target = FileUploadTarget.make()
        let data = try JSONEncoder().encode(target)
        manager.urlSession(backgroundSession, dataTask: task, didReceive: data)
        context.refresh(file, mergeChanges: false)
        XCTAssertNotNil(file)
        XCTAssertEqual(file.target, target)
    }

    func testSessionTaskDidCompleteWithTarget() throws {
        UUID.mock("abcdefg")
        let url = URL(string: "data:text/plain,abcde")!
        let target = FileUploadTarget.make()
        MockURLSession.mock(
            PostFileUploadRequest( fileURL: url, target: target),
            value: APIFile.make(),
            baseURL: target.upload_url,
            accessToken: nil,
            taskID: 1
        )
        let file = context.insert() as File
        file.localFileURL = url
        file.taskID = 0
        file.target = target
        try context.save()
        let task = MockURLSession.MockDataTask()
        task.uploadStep = .target
        task.taskIdentifier = 0
        manager.urlSession(backgroundSession, task: task, didCompleteWithError: nil)
        context.refresh(file, mergeChanges: false)
        XCTAssertEqual(file.taskID, 1)
        let uploadTask = MockURLSession.dataMocks.first { $0.value.taskIdentifier == 1 }?.value
        XCTAssertNotNil(uploadTask)
        XCTAssertEqual(uploadTask?.resumed, true)
        XCTAssertEqual(uploadTask?.uploadStep, .upload)
        UUID.reset()
    }

    func testSessionDataTaskDidReceiveDataUpload() throws {
        let file = context.insert() as File
        file.taskID = 1
        file.id = nil
        try context.save()
        let task = MockURLSession.MockDataTask()
        task.uploadStep = .upload
        task.taskIdentifier = 1
        let result = APIFile.make(id: ID("22"))
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(result)
        manager.urlSession(backgroundSession, dataTask: task, didReceive: data)
        context.refresh(file, mergeChanges: false)
        XCTAssertEqual(file.id, "22")
    }

    func testSessionTaskDidCompleteWithUpload() throws {
        let file = context.insert() as File
        file.taskID = 1
        file.context = .course("1")
        try context.save()
        let task = MockURLSession.MockDataTask()
        task.uploadStep = .upload
        task.taskIdentifier = 1
        XCTAssertTrue(file.isUploading)
        manager.urlSession(backgroundSession, task: task, didCompleteWithError: nil)
        context.refresh(file, mergeChanges: false)
        XCTAssertNil(file.taskID)
        XCTAssertNil(file.uploadError)
        XCTAssertFalse(file.isUploading)
    }

    func testSessionTaskDidCompleteSubmissionUpload() throws {
        Keychain.addEntry(currentSession)
        mockSubmission(courseID: "1", assignmentID: "2", fileIDs: ["3"], taskID: 2)
        let file = context.insert() as File
        file.id = "3"
        file.taskID = 1
        file.context = .submission(courseID: "1", assignmentID: "2")
        file.user = File.User(id: currentSession.userID, baseURL: currentSession.baseURL, actAsUserID: currentSession.actAsUserID)
        try context.save()
        let task = MockURLSession.MockDataTask()
        task.uploadStep = .upload
        task.taskIdentifier = 1
        manager.urlSession(backgroundSession, task: task, didCompleteWithError: nil)
        context.refresh(file, mergeChanges: false)
        XCTAssertEqual(file.taskID, 2)
        let submitTask = MockURLSession.dataMocks.first { $0.value.taskIdentifier == 2 }?.value
        XCTAssertNotNil(submitTask)
        XCTAssertEqual(submitTask?.resumed, true)
        XCTAssertEqual(submitTask?.uploadStep, .submit)
        Keychain.removeEntry(currentSession)
    }

    func testSessionTaskDidCompleteSubmissionBatchUpload() throws {
        Keychain.addEntry(currentSession)
        mockSubmission(courseID: "1", assignmentID: "2", fileIDs: ["1", "2"], taskID: 3)
        let one = context.insert() as File
        one.id = "2"
        one.batchID = "assignment-2"
        one.taskID = 1
        one.context = .submission(courseID: "1", assignmentID: "2")
        one.user = File.User(id: currentSession.userID, baseURL: currentSession.baseURL, actAsUserID: currentSession.actAsUserID)
        let two = context.insert() as File
        two.id = "2"
        two.batchID = "assignment-2"
        two.taskID = 2
        two.context = .submission(courseID: "1", assignmentID: "2")
        two.user = File.User(id: currentSession.userID, baseURL: currentSession.baseURL, actAsUserID: currentSession.actAsUserID)
        try context.save()
        let task = MockURLSession.MockDataTask()
        task.uploadStep = .upload
        task.taskIdentifier = 2
        manager.urlSession(backgroundSession, task: task, didCompleteWithError: nil)
        context.refresh(two, mergeChanges: false)
        XCTAssertEqual(two.taskID, 3)
        let submitTask = MockURLSession.dataMocks.first { $0.value.taskIdentifier == 3 }?.value
        XCTAssertNotNil(submitTask)
        XCTAssertEqual(submitTask?.resumed, true)
        Keychain.removeEntry(currentSession)
    }

    func testSessionDataTaskDidReceiveDataSubmissionSendsNotification() throws {
        let file = context.insert() as File
        file.taskID = 1
        file.context = .submission(courseID: "1", assignmentID: "2")
        try context.save()
        let expectation = XCTestExpectation(description: "notification sent")
        var notification: Notification?
        let name = UploadManager.AssignmentSubmittedNotification
        let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { note in
            notification = note
            expectation.fulfill()
        }
        let task = MockURLSession.MockDataTask()
        task.taskIdentifier = 1
        task.uploadStep = .submit
        let submission = APISubmission.make()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(submission)
        manager.urlSession(backgroundSession, dataTask: task, didReceive: data)
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(notification)
        XCTAssertEqual(notification?.userInfo?["assignmentID"] as? String, "2")
        XCTAssertEqual(notification?.userInfo?["submission"] as? APISubmission, submission)
        NotificationCenter.default.removeObserver(observer)
    }

    func testSessionTaskDidCompleteSubmit() throws {
        let one = context.insert() as File
        one.id = "2"
        one.batchID = "assignment-2"
        one.context = .submission(courseID: "1", assignmentID: "2")
        one.user = File.User(id: currentSession.userID, baseURL: currentSession.baseURL, actAsUserID: currentSession.actAsUserID)
        let two = context.insert() as File
        two.id = "2"
        two.batchID = "assignment-2"
        two.context = .submission(courseID: "1", assignmentID: "2")
        two.taskID = 2
        two.user = File.User(id: currentSession.userID, baseURL: currentSession.baseURL, actAsUserID: currentSession.actAsUserID)
        try context.save()
        let task = MockURLSession.MockDataTask()
        task.uploadStep = .submit
        task.taskIdentifier = 2
        manager.urlSession(backgroundSession, task: task, didCompleteWithError: nil)
        context.refreshAllObjects()
        XCTAssertTrue(one.isFault)
        XCTAssertTrue(two.isFault)
        let notification = notificationCenter.requests.last
        XCTAssertNotNil(notification)
        XCTAssertEqual(notification?.content.title, "Assignment submitted!")
        XCTAssertEqual(notification?.content.body, "Your files were uploaded and the assignment was submitted successfully.")
        XCTAssertEqual(notification?.route, Route.course("1", assignment: "2"))
    }

    func testSessionDataTaskDidReceiveInvalidData() throws {
        let file = context.insert() as File
        file.uploadError = nil
        file.taskID = 1
        file.context = .submission(courseID: "1", assignmentID: "2")
        try context.save()
        let task = MockURLSession.MockDataTask()
        task.uploadStep = .target
        task.taskIdentifier = 1
        let data = "invalid request".data(using: .utf8)!
        manager.urlSession(backgroundSession, dataTask: task, didReceive: data)
        context.refresh(file, mergeChanges: false)
        XCTAssertNotNil(file.uploadError)
        XCTAssertNil(file.taskID)
        let notification = notificationCenter.requests.last
        XCTAssertNotNil(notification)
        XCTAssertEqual(notification?.content.title, "Assignment submission failed!")
        XCTAssertEqual(notification?.content.body, "Something went wrong with an assignment submission.")
        XCTAssertEqual(notification?.route, Route.course("1", assignment: "2"))
    }

    func testFailedSubmissionNotification() throws {
        let file = context.insert() as File
        file.uploadError = nil
        file.taskID = 1
        file.context = .submission(courseID: "1", assignmentID: "2")
        try context.save()
        let task = MockURLSession.MockDataTask()
        task.uploadStep = .target
        task.taskIdentifier = 1
        let data = "invalid request".data(using: .utf8)!
        manager.urlSession(backgroundSession, dataTask: task, didReceive: data)
        let notification = notificationCenter.requests.last
        XCTAssertNotNil(notification)
        XCTAssertEqual(notification?.content.title, "Assignment submission failed!")
        XCTAssertEqual(notification?.content.body, "Something went wrong with an assignment submission.")
        XCTAssertEqual(notification?.route, Route.course("1", assignment: "2"))
    }

    func testCancelBatchID() throws {
        let batchID = "1"
        let one = context.insert() as File
        one.batchID = batchID
        one.user = File.User(id: currentSession.userID, baseURL: currentSession.baseURL, actAsUserID: currentSession.actAsUserID)
        let two = context.insert() as File
        two.batchID = batchID
        two.user = File.User(id: currentSession.userID, baseURL: currentSession.baseURL, actAsUserID: currentSession.actAsUserID)
        two.taskID = 2
        try context.save()
        mockSubmission(courseID: "1", assignmentID: "2", fileIDs: ["1"], taskID: 2)
        let task = MockURLSession.dataMocks.first { $0.value.taskIdentifier == 2 }?.value
        manager.cancel(batchID: batchID)
        context.refreshAllObjects()
        XCTAssertTrue(one.isFault)
        XCTAssertTrue(two.isFault)
        XCTAssertEqual(task?.canceled, true)
    }

    func testSessionTaskDidSendBodyData() throws {
        let file = context.insert() as File
        file.taskID = 1
        file.size = 101
        file.bytesSent = 0
        try context.save()
        let task = MockURLSession.MockDataTask()
        task.taskIdentifier = 1
        manager.urlSession(
            backgroundSession,
            task: task,
            didSendBodyData: 0,
            totalBytesSent: 10,
            totalBytesExpectedToSend: 100
        )
        context.refresh(file, mergeChanges: false)
        XCTAssertEqual(file.size, 100)
        XCTAssertEqual(file.bytesSent, 10)
    }

    func testSessionDidFinishEventsForBackgroundURLSession() {
        let expectation = XCTestExpectation(description: "completion handler called")
        manager.completionHandler = {
            expectation.fulfill()
        }
        manager.urlSessionDidFinishEvents(forBackgroundURLSession: backgroundSession)
        XCTAssertTrue(backgroundSession.finishedTasksAndInvalidated)
        wait(for: [expectation], timeout: 1)
    }

    private func mockSubmission(courseID: String, assignmentID: String, fileIDs: [String], taskID: Int) {
        let submission = CreateSubmissionRequest.Body.Submission(
            text_comment: nil,
            submission_type: .online_upload,
            body: nil,
            url: nil,
            file_ids: fileIDs,
            media_comment_id: nil,
            media_comment_type: nil
        )
        let submissionRequest = CreateSubmissionRequest(
            context: ContextModel(.course, id: courseID),
            assignmentID: assignmentID,
            body: .init(submission: submission)
        )
        MockURLSession.mock(
            submissionRequest,
            value: APISubmission.make(),
            baseURL: currentSession.baseURL,
            accessToken: currentSession.accessToken,
            taskID: taskID
        )
    }

    private func mockTarget(name: String, size: Int, context: FileUploadContext) {
        let body = PostFileUploadTargetRequest.Body(name: name, on_duplicate: .rename, parent_folder_id: nil, size: size)
        let requestable = PostFileUploadTargetRequest(context: context, body: body)
        MockURLSession.mock(
            requestable,
            value: FileUploadTarget.make(),
            baseURL: AppEnvironment.shared.api.baseURL,
            accessToken: AppEnvironment.shared.api.accessToken,
            taskID: 0
        )
    }
}
