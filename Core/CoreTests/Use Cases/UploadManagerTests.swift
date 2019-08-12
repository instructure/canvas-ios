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
import TestsFoundation
@testable import Core
import XCTest
import CoreData

class UploadManagerTests: CoreTestCase {
    let uploadContext: FileUploadContext = .course("1")
    let backgroundSession = MockURLSession()
    let manager = UploadManager()
    var context: NSManagedObjectContext {
        return NSPersistentContainer.shared.viewContext
    }
    lazy var url: URL = {
        let url = URL.temporaryDirectory.appendingPathComponent("upload-manager.txt")
        FileManager.default.createFile(atPath: url.path, contents: "hey".data(using: .utf8), attributes: nil)
        return url
    }()
    lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    override func setUp() {
        super.setUp()

        manager.notificationManager = notificationManager
        URLSessionAPI.delegateURLSession = { _, _, _ in self.backgroundSession }
        MockURLSession.reset()
    }

    func testUploadURLDefault() throws {
        UUID.mock("default")
        let expected = URL
            .temporaryDirectory
            .appendingPathComponent("uploads/default/")
            .appendingPathComponent(url.lastPathComponent)
        XCTAssertEqual(try manager.uploadURL(url), expected)
    }

    func testUploadURLSharedContainer() throws {
        UUID.mock("shared")
        let expected = URL
            .sharedContainer("group.com.instructure.icanvas")?
            .appendingPathComponent("uploads/shared/")
            .appendingPathComponent(url.lastPathComponent)
        let config = URLSessionConfiguration.background(withIdentifier: "doesnt matter")
        config.sharedContainerIdentifier = "group.com.instructure.icanvas"
        backgroundSession.config = config
        XCTAssertEqual(try manager.uploadURL(url), expected)
    }

    func testAddAndSubscribe() throws {
        let expectation = XCTestExpectation(description: "subscribe event")
        let store = manager.subscribe(batchID: "1") {
            expectation.fulfill()
        }
        let url = URL.temporaryDirectory.appendingPathComponent("upload-manager-add-test.txt")
        FileManager.default.createFile(atPath: url.path, contents: "hello".data(using: .utf8), attributes: nil)
        manager.add(url: url, batchID: "1")
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(store.count, 1)
    }

    func testSubscribeScopedToBatchAndUser() {
        let good = context.insert() as File
        good.displayName = "Good subscribe file"
        good.batchID = "1"
        good.setUser(session: currentSession)
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
        file.targetData = try encoder.encode(target)
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

    func testSessionTaskDidCompleteWithUpload() throws {
        let file = context.insert() as File
        file.id = nil
        file.taskID = 1
        file.context = .course("1")
        file.uploadData = try encoder.encode(APIFile.make(id: "1"))
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
        XCTAssertEqual(file.id, "1")
    }

    func testSessionTaskDidCompleteSubmissionUpload() throws {
        LoginSession.add(currentSession)
        mockSubmission(courseID: "1", assignmentID: "2", fileIDs: ["3"], comment: "test comment", taskID: 2)
        let file = context.insert() as File
        file.id = "3"
        file.taskID = 1
        file.context = .submission(courseID: "1", assignmentID: "2", comment: "test comment")
        file.uploadData = try encoder.encode(APIFile.make(id: "1"))
        file.setUser(session: currentSession)
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
        LoginSession.remove(currentSession)
    }

    func testSessionTaskDidCompleteSubmissionBatchUpload() throws {
        LoginSession.add(currentSession)
        mockSubmission(courseID: "1", assignmentID: "2", fileIDs: ["1", "2"], taskID: 3)
        let one = context.insert() as File
        one.id = "2"
        one.batchID = "assignment-2"
        one.taskID = 1
        one.context = .submission(courseID: "1", assignmentID: "2", comment: nil)
        one.setUser(session: currentSession)
        let two = context.insert() as File
        two.batchID = "assignment-2"
        two.taskID = 2
        two.context = .submission(courseID: "1", assignmentID: "2", comment: nil)
        two.uploadData = try encoder.encode(APIFile.make(id: "2"))
        two.setUser(session: currentSession)
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
        LoginSession.remove(currentSession)
    }

    func testSessionTaskDidComplete201Error() throws {
        LoginSession.add(currentSession)
        let file = context.insert() as File
        file.id = nil
        file.taskID = 1
        file.context = .submission(courseID: "1", assignmentID: "2", comment: "test comment")
        file.setUser(session: currentSession)
        try context.save()

        let location = "https://canvas.instructure.com/api/v1/files/1"
        let task = MockURLSession.MockDataTask()
        let response = HTTPURLResponse(url: URL(string: "https://inst-fs.com")!, statusCode: 201, httpVersion: nil, headerFields: [HttpHeader.location: location])
        task.mock = MockURLSession.MockData(data: nil, response: response, error: nil)
        task.uploadStep = .upload
        task.taskIdentifier = 1
        var request = URLRequest(url: URL(string: location)!)
        request.setValue("Bearer \(currentSession.accessToken)", forHTTPHeaderField: HttpHeader.authorization)
        request.setValue("application/json+canvas-string-ids", forHTTPHeaderField: HttpHeader.accept)
        let locationTask = MockURLSession.mock(request, taskID: 2)

        manager.urlSession(backgroundSession, task: task, didCompleteWithError: NSError.instructureError("Sike! File not found even though it's a 201!"))
        context.refresh(file, mergeChanges: false)
        XCTAssertEqual(file.taskID, 2)
        XCTAssertTrue(locationTask.resumed)
        XCTAssertEqual(locationTask.uploadStep, .upload)
        LoginSession.remove(currentSession)
    }

    func testSessionTaskDidCompleteSubmit() throws {
        let fileManager = FileManager.default
        let oneURL = URL.temporaryDirectory.appendingPathComponent("oneURL.txt")
        try "one".write(to: oneURL, atomically: false, encoding: .utf8)
        let twoURL = URL.temporaryDirectory.appendingPathComponent("twoURL.txt")
        try "two".write(to: twoURL, atomically: false, encoding: .utf8)
        XCTAssertTrue(fileManager.fileExists(atPath: oneURL.path))
        XCTAssertTrue(fileManager.fileExists(atPath: twoURL.path))

        let one = context.insert() as File
        one.id = "2"
        one.batchID = "assignment-2"
        one.context = .submission(courseID: "1", assignmentID: "2", comment: nil)
        one.localFileURL = oneURL
        one.setUser(session: currentSession)
        let two = context.insert() as File
        two.id = "2"
        two.batchID = "assignment-2"
        two.context = .submission(courseID: "1", assignmentID: "2", comment: nil)
        two.taskID = 2
        two.localFileURL = twoURL
        two.setUser(session: currentSession)
        two.submitData = try encoder.encode(APISubmission.make())
        try context.save()
        let task = MockURLSession.MockDataTask()
        task.uploadStep = .submit
        task.taskIdentifier = 2
        manager.urlSession(backgroundSession, task: task, didCompleteWithError: nil)
        let store = manager.subscribe(batchID: "assignment-2", eventHandler: {})
        XCTAssertEqual(store.count, 0)
        let notification = notificationCenter.requests.last
        XCTAssertNotNil(notification)
        XCTAssertEqual(notification?.content.title, "Assignment submitted!")
        XCTAssertEqual(notification?.content.body, "Your files were uploaded and the assignment was submitted successfully.")
        XCTAssertEqual(notification?.route, Route.course("1", assignment: "2"))
        XCTAssertFalse(fileManager.fileExists(atPath: oneURL.path))
        XCTAssertFalse(fileManager.fileExists(atPath: twoURL.path))
    }

    func testSessionDataTaskDidReceiveData() throws {
        let file = context.insert() as File
        file.targetData = nil
        file.uploadData = nil
        file.submitData = nil
        file.taskID = 1
        file.context = .submission(courseID: "1", assignmentID: "2", comment: nil)
        try context.save()
        let task = MockURLSession.MockDataTask()
        task.uploadStep = .target
        task.taskIdentifier = 1

        let data = "hello".data(using: .utf8)!
        manager.urlSession(backgroundSession, dataTask: task, didReceive: data)
        context.refresh(file, mergeChanges: false)
        XCTAssertNotNil(file.targetData)

        task.uploadStep = .upload
        manager.urlSession(backgroundSession, dataTask: task, didReceive: data)
        context.refresh(file, mergeChanges: false)
        XCTAssertNotNil(file.uploadData)

        task.uploadStep = .submit
        manager.urlSession(backgroundSession, dataTask: task, didReceive: data)
        context.refresh(file, mergeChanges: false)
        XCTAssertNotNil(file.submitData)
    }

    func testFailedSubmissionNotification() throws {
        let file = context.insert() as File
        file.uploadError = nil
        file.taskID = 1
        file.context = .submission(courseID: "1", assignmentID: "2", comment: nil)
        try context.save()
        let task = MockURLSession.MockDataTask()
        task.uploadStep = .upload
        task.taskIdentifier = 1
        manager.urlSession(backgroundSession, task: task, didCompleteWithError: NSError.instructureError("invalid request"))
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
        one.setUser(session: currentSession)
        let two = context.insert() as File
        two.batchID = batchID
        two.setUser(session: currentSession)
        two.taskID = 2
        try context.save()
        mockSubmission(courseID: "1", assignmentID: "2", fileIDs: ["1"], taskID: 2)
        let task = MockURLSession.dataMocks.first { $0.value.taskIdentifier == 2 }?.value
        manager.cancel(batchID: batchID)
        let store = manager.subscribe(batchID: batchID, eventHandler: {})
        XCTAssertEqual(store.count, 0)
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
        task.uploadStep = .upload
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

    private func mockSubmission(courseID: String, assignmentID: String, fileIDs: [String], comment: String? = nil, taskID: Int) {
        let submission = CreateSubmissionRequest.Body.Submission(
            text_comment: comment,
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

    private func mockTarget(name: String, size: Int, context: FileUploadContext, taskID: Int = 0) {
        let body = PostFileUploadTargetRequest.Body(name: name, on_duplicate: .rename, parent_folder_id: nil, size: size)
        let requestable = PostFileUploadTargetRequest(context: context, body: body)
        MockURLSession.mock(
            requestable,
            value: FileUploadTarget.make(),
            baseURL: AppEnvironment.shared.api.baseURL,
            accessToken: AppEnvironment.shared.api.accessToken,
            taskID: taskID
        )
    }
}
