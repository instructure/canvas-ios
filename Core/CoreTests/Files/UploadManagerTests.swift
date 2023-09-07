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
        func performExpiringActivity(reason: String, completion: @escaping (Bool) -> Void) {
            completion(false)
        }
    }

    let uploadContext: FileUploadContext = .context(Context(.course, id: "1"))
    let manager = UploadManager(identifier: "upload-manager-tests")
    var context: NSManagedObjectContext {
        return UploadManager.shared.viewContext
    }
    lazy var url: URL = {
        let url = URL.Directories.temporary.appendingPathComponent("upload-manager.txt")
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
            .Directories
            .temporary
            .appendingPathComponent("uploads/default/")
            .appendingPathComponent(url.lastPathComponent)
        XCTAssertEqual(try manager.copyFileToSharedContainer(url), expected)
    }

    func testUploadURLSharedContainer() throws {
        UUID.mock("shared")
        let expected = URL
            .Directories
            .sharedContainer(appGroup: "group.com.instructure.icanvas.2u")?
            .appendingPathComponent("uploads/shared/")
            .appendingPathComponent(url.lastPathComponent)
        let manager = UploadManager(identifier: "test", sharedContainerIdentifier: "group.com.instructure.icanvas.2u")
        XCTAssertEqual(try manager.copyFileToSharedContainer(url), expected)
    }

    func testAddAndSubscribe() throws {
        let expectation = XCTestExpectation(description: "subscribe event")
        let store = manager.subscribe(batchID: "1") {
            expectation.fulfill()
        }
        let url = URL.Directories.temporary.appendingPathComponent("upload-manager-add-test.txt")
        FileManager.default.createFile(atPath: url.path, contents: "hello".data(using: .utf8), attributes: nil)
        try manager.add(url: url, batchID: "1")
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(store.count, 1)
        let file = try XCTUnwrap(store.first)
        XCTAssertGreaterThan(file.size, 0)
    }

    func testSubscribeScopedToBatchAndUser() {
        let good = context.insert() as File
        good.filename = "good.file"
        good.displayName = "Good subscribe file"
        good.batchID = "1"
        good.setUser(session: currentSession)
        let badBatch = context.insert() as File
        badBatch.filename = "badBatch.file"
        badBatch.batchID = "2"
        badBatch.user = good.user
        let badUser = context.insert() as File
        badUser.filename = "badUser.file"
        badUser.batchID = good.batchID
        badUser.user = File.User(id: "bad", baseURL: currentSession.baseURL, masquerader: nil)
        try! context.save()
        let store = manager.subscribe(batchID: good.batchID!) {}
        XCTAssertEqual(store.count, 1)
        XCTAssertEqual(store.first, good)
    }

    func testUploadBatch() throws {
        let file = try manager.add(url: url, batchID: "1")
        let mock = mockUpload(fileURL: file.localFileURL!, target: mockTarget(name: url.lastPathComponent, size: 0, context: uploadContext))
        mock.suspend()
        manager.upload(batch: "1", to: uploadContext)
        XCTAssertEqual(mock.queue.first?.state, .running)
    }

    func testUploadURL() throws {
        let mock = mockUpload(fileURL: url, target: mockTarget(name: url.lastPathComponent, size: 0, context: uploadContext))
        mock.suspend()
        manager.upload(url: url, batchID: "testBatchID", to: uploadContext)
        XCTAssertEqual(mock.queue.first?.state, .running)
    }

    func testUploadFile() throws {
        let file = try manager.add(url: url, batchID: "1")
        let mock = mockUpload(fileURL: file.localFileURL!, target: mockTarget(name: url.lastPathComponent, size: 0, context: uploadContext), taskID: "1")
        mock.suspend()
        UUID.mock("1")
        manager.upload(file: file, to: .context(Context(.course, id: "1")))
        XCTAssertEqual(mock.queue.first?.state, .running)
        context.refresh(file, mergeChanges: true)
        XCTAssertEqual(file.taskID, "1")
    }

    func testSessionTaskDidCompleteWithUpload() throws {
        LoginSession.add(currentSession)
        let file = try manager.add(url: url, batchID: "testBatchID")
        file.taskID = "1"
        try context.save()
        XCTAssertTrue(file.isUploading)
        let data = try encoder.encode(APIFile.make(id: "1"))
        let task = manager.backgroundSession.dataTask(with: URLRequest(url: URL(string: "/")!))
        task.taskID = "1"
        manager.urlSession(manager.backgroundSession, dataTask: task, didReceive: data)
        manager.urlSession(manager.backgroundSession, task: task, didCompleteWithError: nil)
        context.refresh(file, mergeChanges: true)
        XCTAssertNil(file.taskID)
        XCTAssertNil(file.uploadError)
        XCTAssertFalse(file.isUploading)
        XCTAssertEqual(file.id, "1")
    }

    func testSessionTaskDidCompleteSubmissionUpload() throws {
        let fileManager = FileManager.default
        let oneURL = URL.Directories.temporary.appendingPathComponent("oneURL.txt")
        try "one".write(to: oneURL, atomically: false, encoding: .utf8)
        let twoURL = URL.Directories.temporary.appendingPathComponent("twoURL.txt")
        try "two".write(to: twoURL, atomically: false, encoding: .utf8)
        XCTAssertTrue(fileManager.fileExists(atPath: oneURL.path))
        XCTAssertTrue(fileManager.fileExists(atPath: twoURL.path))
        LoginSession.add(currentSession)
        let task1 = manager.backgroundSession.dataTask(with: URLRequest(url: URL(string: "/")!))
        task1.taskID = "1"
        let task2 = manager.backgroundSession.dataTask(with: URLRequest(url: URL(string: "/")!))
        task2.taskID = "2"
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

        manager.urlSession(manager.backgroundSession, dataTask: task1, didReceive: data1)
        manager.urlSession(manager.backgroundSession, dataTask: task2, didReceive: data2)
        manager.urlSession(manager.backgroundSession, task: task1, didCompleteWithError: nil)
        manager.urlSession(manager.backgroundSession, task: task2, didCompleteWithError: nil)

        let store = manager.subscribe(batchID: "assignment-2", eventHandler: {})
        XCTAssertEqual(store.count, 0)
        let notification = notificationCenter.requests.last
        XCTAssertNotNil(notification)
        XCTAssertEqual(notification?.content.title, "Assignment submitted!")
        XCTAssertEqual(notification?.content.body, "Your files were uploaded and the assignment was submitted successfully.")
        XCTAssertEqual(notification?.route, "/courses/1/assignments/2")
        XCTAssertTrue(fileManager.fileExists(atPath: oneURL.path))
        XCTAssertTrue(fileManager.fileExists(atPath: twoURL.path))
    }

    func testFailedSubmissionNotification() throws {
        let file = context.insert() as File
        file.filename = "file"
        file.uploadError = nil
        file.taskID = "1"
        file.context = .submission(courseID: "1", assignmentID: "2", comment: nil)
        try context.save()
        let task = manager.backgroundSession.dataTask(with: URLRequest(url: URL(string: "/")!))
        task.taskID = "1"
        manager.urlSession(manager.backgroundSession, task: task, didCompleteWithError: NSError.instructureError("invalid request"))
        let notification = notificationCenter.requests.last
        XCTAssertNotNil(notification)
        XCTAssertEqual(notification?.content.title, "Assignment submission failed!")
        XCTAssertEqual(notification?.content.body, "Something went wrong with an assignment submission.")
        XCTAssertEqual(notification?.route, "/courses/1/assignments/2")
    }

    func testFailedNotification() throws {
        manager.notificationManager.sendFailedNotification()
        let notification = notificationCenter.requests.last
        XCTAssertNotNil(notification)
        XCTAssertEqual(notification?.content.title, "Failed to send files!")
        XCTAssertEqual(notification?.content.body, "Something went wrong with uploading files.")
    }

    func testCancelBatchID() throws {
        let batchID = "1"
        let one = context.insert() as File
        one.filename = "one"
        one.batchID = batchID
        one.setUser(session: currentSession)
        let two = context.insert() as File
        two.filename = "two"
        two.batchID = batchID
        two.setUser(session: currentSession)
        two.taskID = "2"
        try context.save()
        let task = manager.backgroundSession.dataTask(with: URL(string: "https://canvas.instructure.com")!)
        task.taskID = "1"
        task.resume()
        manager.cancel(batchID: batchID)
        let store = manager.subscribe(batchID: batchID, eventHandler: {})
        XCTAssertEqual(store.count, 0)
    }

    func testSessionTaskDidSendBodyData() throws {
        let file = context.insert() as File
        file.filename = "filename"
        file.taskID = "1"
        file.size = 101
        file.bytesSent = 0
        try context.save()
        let task = manager.backgroundSession.dataTask(with: URL(string: "/")!)
        task.taskID = "1"
        manager.urlSession(
            manager.backgroundSession,
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
        manager.completionHandler = expectation.fulfill
        manager.urlSessionDidFinishEvents(forBackgroundURLSession: manager.backgroundSession)
        wait(for: [expectation], timeout: 1.0)
    }

    func testMarkInterruptedSubmissionAsFailed() {
        // Without any submissions the assignment's submissionState will be .unsubmitted
        let assignment = Assignment.save(.make(id: ID("testAssignmentID")), in: context, updateSubmission: false, updateScoreStatistics: false)
        let file = File(context: context)
        file.batchID = "assignment-testAssignmentID"
        file.id = "uploadedToFileServerID"
        file.filename = "testFileName"
        file.setUser(session: environment.currentSession!)
        XCTAssertNoThrow(try context.save())
        XCTAssertNil(file.uploadError)

        manager.cleanupDanglingFiles(assignment: assignment)

        XCTAssertNotNil(file.uploadError)
        XCTAssertNil(file.id)
    }

    func testDeleteAlreadyUploadedFiles() {
        // Setup assignment received from the API
        let apiFile = APIFile.make(id: "uploadedID")
        let apiSubmission = APISubmission.make(attachments: [apiFile])
        let apiAssignment = Assignment.save(.make(id: ID("testAssignmentID"), submission: apiSubmission), in: context, updateSubmission: true, updateScoreStatistics: false)

        // Create a binary file to check if it gets deleted
        let fileManager = FileManager.default
        let binaryURL = URL.Directories.temporary.appendingPathComponent("binaryURL.txt")
        XCTAssertNoThrow(try "one".write(to: binaryURL, atomically: false, encoding: .utf8))
        XCTAssertTrue(fileManager.fileExists(atPath: binaryURL.path))

        // Simulate already uploaded file dangling in the DB
        let localFile = File(context: context)
        localFile.batchID = "assignment-testAssignmentID"
        localFile.id = "uploadedID"
        localFile.filename = "testFileName"
        localFile.localFileURL = binaryURL
        localFile.setUser(session: environment.currentSession!)
        XCTAssertFalse(localFile.isFault)

        manager.cleanupDanglingFiles(assignment: apiAssignment)

        XCTAssertTrue(localFile.isFault)
        XCTAssertFalse(fileManager.fileExists(atPath: binaryURL.path))
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
        API(currentSession).mock(submissionRequest, value: .make() /*, taskDescription: taskID */)
    }

    @discardableResult
    private func mockTarget(name: String, size: Int, context: FileUploadContext) -> FileUploadTarget {
        let body = PostFileUploadTargetRequest.Body(name: name, on_duplicate: .rename, parent_folder_id: nil, size: size)
        let target = FileUploadTarget.make()
        api.mock(PostFileUploadTargetRequest(context: context, body: body), value: target)
        return target
    }

    @discardableResult
    private func mockUpload(fileURL: URL, target: FileUploadTarget, taskID: String = "1") -> APIMock {
        let requestable = PostFileUploadRequest(fileURL: fileURL, target: target)
        return API(baseURL: target.upload_url, urlSession: manager.backgroundSession)
            .mock(requestable, value: .make() /*, taskDescription: taskID */)
    }
}
