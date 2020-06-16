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
    struct TestProcess: ProcessManager {
        func performExpiringActivity(withReason reason: String, using block: @escaping (Bool) -> Void) {
            block(false)
        }
    }

    let uploadContext: FileUploadContext = .context(Context(.course, id: "1"))
    let backgroundSession = MockURLSession()
    let manager = UploadManager(identifier: "upload-manager-tests")
    var context: NSManagedObjectContext {
        return UploadManager.shared.viewContext
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
        LoginSession.clearAll()
        manager.process = TestProcess()
        UUID.mock("abcdefg")
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
        URLSessionAPI.delegateURLSession = { (configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue: OperationQueue?) -> URLSession in
            return URLSession(configuration: config, delegate: delegate, delegateQueue: delegateQueue)
        }
        let manager = UploadManager(identifier: "test", sharedContainerIdentifier: "group.com.instructure.icanvas")
        XCTAssertEqual(try manager.uploadURL(url), expected)
    }

    func testAddAndSubscribe() throws {
        let expectation = XCTestExpectation(description: "subscribe event")
        let store = manager.subscribe(batchID: "1") {
            expectation.fulfill()
        }
        let url = URL.temporaryDirectory.appendingPathComponent("upload-manager-add-test.txt")
        FileManager.default.createFile(atPath: url.path, contents: "hello".data(using: .utf8), attributes: nil)
        try manager.add(url: url, batchID: "1")
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(store.count, 1)
        let file = try XCTUnwrap(store.first)
        XCTAssertGreaterThan(file.size, 0)
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
        badUser.user = File.User(id: "bad", baseURL: currentSession.baseURL, masquerader: nil)
        try! context.save()
        let store = manager.subscribe(batchID: good.batchID!) {}
        XCTAssertEqual(store.count, 1)
        XCTAssertEqual(store.first, good)
    }

    func testUploadBatch() throws {
        let file = try manager.add(url: url, batchID: "1")
        mockUpload(fileURL: file.localFileURL!, target: mockTarget(name: url.lastPathComponent, size: 0, context: uploadContext))
        let expectation = XCTestExpectation(description: "callback was called")
        manager.upload(batch: "1", to: uploadContext, callback: expectation.fulfill)
        wait(for: [expectation], timeout: 1)
        let tasks = MockURLSession.dataMocks.values
        XCTAssertEqual(tasks.count, 2) // target and upload
        XCTAssertTrue(tasks.allSatisfy { $0.resumed })
    }

    func testUploadURL() throws {
        mockUpload(fileURL: url, target: mockTarget(name: url.lastPathComponent, size: 0, context: uploadContext))
        let expectation = XCTestExpectation(description: "callback was called")
        manager.upload(url: url, to: uploadContext, callback: expectation.fulfill)
        wait(for: [expectation], timeout: 1)
        let tasks = MockURLSession.dataMocks.values
        XCTAssertEqual(tasks.count, 2) // target and upload
        XCTAssertTrue(tasks.allSatisfy { $0.resumed })
    }

    func testUploadFile() throws {
        let file = try manager.add(url: url, batchID: "1")
        mockUpload(fileURL: file.localFileURL!, target: mockTarget(name: url.lastPathComponent, size: 0, context: uploadContext), taskID: "1")
        let expectation = XCTestExpectation(description: "callback was called")
        UUID.mock("1")
        manager.upload(file: file, to: .context(Context(.course, id: "1")), callback: expectation.fulfill)
        wait(for: [expectation], timeout: 1)
        let tasks = MockURLSession.dataMocks.values
        XCTAssertEqual(tasks.count, 2) // target and upload
        XCTAssertTrue(tasks.allSatisfy { $0.resumed })
        context.refresh(file, mergeChanges: true)
        XCTAssertEqual(file.taskID, "1")
    }

    func testSessionTaskDidCompleteWithUpload() throws {
        LoginSession.add(currentSession)
        let task = MockURLSession.MockDataTask()
        task.mock = MockURLSession.MockData(data: nil, response: nil, error: nil)
        task.taskDescription = "1"
        let file = try manager.add(url: url)
        file.taskID = "1"
        try context.save()
        XCTAssertTrue(file.isUploading)
        let data = try encoder.encode(APIFile.make(id: "1"))
        manager.urlSession(backgroundSession, dataTask: task, didReceive: data)
        manager.urlSession(backgroundSession, task: task, didCompleteWithError: nil)
        context.refresh(file, mergeChanges: true)
        XCTAssertNil(file.taskID)
        XCTAssertNil(file.uploadError)
        XCTAssertFalse(file.isUploading)
        XCTAssertEqual(file.id, "1")
    }

    func testSessionTaskDidCompleteSubmissionUpload() throws {
        let fileManager = FileManager.default
        let oneURL = URL.temporaryDirectory.appendingPathComponent("oneURL.txt")
        try "one".write(to: oneURL, atomically: false, encoding: .utf8)
        let twoURL = URL.temporaryDirectory.appendingPathComponent("twoURL.txt")
        try "two".write(to: twoURL, atomically: false, encoding: .utf8)
        XCTAssertTrue(fileManager.fileExists(atPath: oneURL.path))
        XCTAssertTrue(fileManager.fileExists(atPath: twoURL.path))
        LoginSession.add(currentSession)
        let task1 = MockURLSession.MockDataTask()
        task1.taskDescription = "1"
        let task2 = MockURLSession.MockDataTask()
        task2.taskDescription = "2"
        mockSubmission(courseID: "1", assignmentID: "2", fileIDs: ["1", "2"], taskID: "3")

        let one = try manager.add(url: oneURL, batchID: "assignment-2")
        one.taskID = "1"
        one.context = .submission(courseID: "1", assignmentID: "2", comment: nil)
        let two = try manager.add(url: twoURL, batchID: "assignment-2")
        two.taskID = "2"
        two.context = .submission(courseID: "1", assignmentID: "2", comment: nil)
        try context.save()

        let data1 = try encoder.encode(APIFile.make(id: "1"))
        let data2 = try encoder.encode(APIFile.make(id: "1"))

        manager.urlSession(backgroundSession, dataTask: task1, didReceive: data1)
        manager.urlSession(backgroundSession, dataTask: task2, didReceive: data2)
        manager.urlSession(backgroundSession, task: task1, didCompleteWithError: nil)
        manager.urlSession(backgroundSession, task: task2, didCompleteWithError: nil)

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

    func testFailedSubmissionNotification() throws {
        let file = context.insert() as File
        file.uploadError = nil
        file.taskID = "1"
        file.context = .submission(courseID: "1", assignmentID: "2", comment: nil)
        try context.save()
        let task = MockURLSession.MockDataTask()
        task.taskDescription = "1"
        manager.urlSession(backgroundSession, task: task, didCompleteWithError: NSError.instructureError("invalid request"))
        let notification = notificationCenter.requests.last
        XCTAssertNotNil(notification)
        XCTAssertEqual(notification?.content.title, "Assignment submission failed!")
        XCTAssertEqual(notification?.content.body, "Something went wrong with an assignment submission.")
        XCTAssertEqual(notification?.route, Route.course("1", assignment: "2"))
    }

    func testFailedNotification() throws {
        manager.sendFailedNotification()
        let notification = notificationCenter.requests.last
        XCTAssertNotNil(notification)
        XCTAssertEqual(notification?.content.title, "Failed to send files!")
        XCTAssertEqual(notification?.content.body, "Something went wrong with uploading files.")
    }

    func testCancelBatchID() throws {
        let batchID = "1"
        let one = context.insert() as File
        one.batchID = batchID
        one.setUser(session: currentSession)
        let two = context.insert() as File
        two.batchID = batchID
        two.setUser(session: currentSession)
        two.taskID = "2"
        try context.save()
        mockSubmission(courseID: "1", assignmentID: "2", fileIDs: ["1"], taskID: "2")
        let task = MockURLSession.dataMocks.first { $0.value.taskDescription == "2" }?.value
        manager.cancel(batchID: batchID)
        let store = manager.subscribe(batchID: batchID, eventHandler: {})
        XCTAssertEqual(store.count, 0)
        XCTAssertEqual(task?.canceled, true)
    }

    func testSessionTaskDidSendBodyData() throws {
        let file = context.insert() as File
        file.taskID = "1"
        file.size = 101
        file.bytesSent = 0
        try context.save()
        let task = MockURLSession.MockDataTask()
        task.taskDescription = "1"
        manager.urlSession(
            backgroundSession,
            task: task,
            didSendBodyData: 0,
            totalBytesSent: 10,
            totalBytesExpectedToSend: 100
        )
        context.refresh(file, mergeChanges: true)
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

    private func mockSubmission(courseID: String, assignmentID: String, fileIDs: [String], comment: String? = nil, taskID: String, accessToken: String? = nil) {
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
            context: .course(courseID),
            assignmentID: assignmentID,
            body: .init(submission: submission)
        )
        MockURLSession.mock(
            submissionRequest,
            value: APISubmission.make(),
            baseURL: currentSession.baseURL,
            accessToken: accessToken ?? currentSession.accessToken,
            taskDescription: taskID
        )
    }

    @discardableResult
    private func mockTarget(name: String, size: Int, context: FileUploadContext) -> FileUploadTarget {
        let body = PostFileUploadTargetRequest.Body(name: name, on_duplicate: .rename, parent_folder_id: nil, size: size)
        let requestable = PostFileUploadTargetRequest(context: context, body: body)
        let target = FileUploadTarget.make()
        MockURLSession.mock(
            requestable,
            value: target,
            baseURL: AppEnvironment.shared.api.baseURL,
            accessToken: AppEnvironment.shared.api.loginSession?.accessToken
        )
        return target
    }

    private func mockUpload(fileURL: URL, target: FileUploadTarget, taskID: String = "1") {
        let requestable = PostFileUploadRequest(fileURL: fileURL, target: target)
        MockURLSession.mock(
            requestable,
            value: APIFile.make(),
            baseURL: target.upload_url,
            accessToken: nil,
            taskDescription: taskID
        )
    }

    private func mockGetFile() -> URLSessionTask {
        let location = "https://canvas.instructure.com/api/v1/files/1"
        let task = MockURLSession.MockDataTask()
        let response = HTTPURLResponse(url: URL(string: "https://inst-fs.com")!, statusCode: 201, httpVersion: nil, headerFields: [HttpHeader.location: location])
        task.mock = MockURLSession.MockData(data: nil, response: response, error: nil)
        task.taskIdentifier = 1
        var request = URLRequest(url: URL(string: location)!)
        request.setValue("Bearer \(currentSession.accessToken!)", forHTTPHeaderField: HttpHeader.authorization)
        request.setValue("application/json+canvas-string-ids", forHTTPHeaderField: HttpHeader.accept)
        MockURLSession.mock(request, taskDescription: "2")
        return task
    }
}
