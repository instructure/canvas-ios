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
import TestsFoundation

class BackgroundURLSessionManagerTests: CoreTestCase {
    var manager: BackgroundURLSessionManager!
    let appGroup = "app.group"

    override func setUp() {
        super.setUp()
        manager = BackgroundURLSessionManager(appGroup: appGroup, database: database)
    }

    func testMainDoesNotExist() {
        manager.complete(session: manager.main)
        let session = manager.main
        XCTAssertEqual(session.configuration.identifier, "com.instructure.CoreTester.background-session")
        XCTAssertEqual(session.configuration.sharedContainerIdentifier, appGroup)
        XCTAssertNotNil(session.delegate)
    }

    func testMainExists() {
        let session = manager.create(withIdentifier: "identifier")
        XCTAssertEqual(session.configuration.identifier, "identifier")
        XCTAssertEqual(session.configuration.sharedContainerIdentifier, appGroup)
        XCTAssertNotNil(session.delegate)
    }

    func testCompleteCallsCompletion() {
        let id = "id.extension"
        let session = manager.create(withIdentifier: id)
        let expectation = XCTestExpectation(description: "completion was called")
        manager.add(completionHandler: expectation.fulfill, forIdentifier: id)
        manager.complete(session: session)
        wait(for: [expectation], timeout: 0.1)
    }
}

class BackgroundURLSessionDelegateTests: CoreTestCase {
    class EventHandler: BackgroundURLSessionDelegateEventHandler {
        var didFinishEvent: Bool = false
        var didFinishEvents: Bool = false

        func urlSessionDidFinishEvent(forBackgroundURLSession session: URLSession) {
            didFinishEvent = true
        }

        func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
            didFinishEvents = true
        }
    }

    var model: BackgroundURLSessionDelegate!
    var session: URLSession!
    let eventHandler = EventHandler()
    let task = MockAPITask(taskIdentifier: 32)
    let backgroundSessionID = "com.instructure.CoreTester.background-session"

    override func setUp() {
        super.setUp()
        model = BackgroundURLSessionDelegate(eventHandler: eventHandler, database: database, queue: queue)
        let manager = BackgroundURLSessionManager(appGroup: "app.group", database: database)
        session = manager.main
        startFileUpload()
    }

    func testURLSessionTaskDidSendBodyData() {
        model.urlSession(session, task: task, didSendBodyData: 0, totalBytesSent: 10, totalBytesExpectedToSend: 100)
        queue.waitUntilAllOperationsAreFinished()
        let fileUpload: FileUpload = databaseClient.fetch().first!
        XCTAssertEqual(fileUpload.bytesSent, 10)
    }

    func testURLSessionDataTaskDidReceiveData() {
        let encoder = JSONEncoder()
        let file = ["id": 42]
        let data = try! encoder.encode(file)
        model.urlSession(session, dataTask: task, didReceive: data)
        queue.waitUntilAllOperationsAreFinished()
        let fileUpload: FileUpload = databaseClient.fetch().first!
        XCTAssertEqual(fileUpload.fileID, "42")
        XCTAssertNil(fileUpload.error)
    }

    func testURLSessionDataTaskDidReceiveDataInvalid() {
        let encoder = JSONEncoder()
        let response = ["error_code": 42]
        let data = try! encoder.encode(response)
        model.urlSession(session, dataTask: task, didReceive: data)
        queue.waitUntilAllOperationsAreFinished()
        let fileUpload: FileUpload = databaseClient.fetch().first!
        XCTAssertNotNil(fileUpload.error)
        XCTAssertNil(fileUpload.fileID)
    }

    func testURLSessionDidCompleteWithError() {
        let error = NSError.instructureError("upload failed")
        model.urlSession(session, task: task, didCompleteWithError: error)
        queue.waitUntilAllOperationsAreFinished()
        let fileUpload: FileUpload = databaseClient.fetch().first!
        XCTAssertFalse(fileUpload.completed)
        XCTAssertEqual(fileUpload.error, "upload failed")
        XCTAssert(eventHandler.didFinishEvent)
    }

    func testURLSessionDidCompleteWithoutError() {
        let error = NSError.instructureError("upload failed")
        model.urlSession(session, task: task, didCompleteWithError: error)
        queue.waitUntilAllOperationsAreFinished()
        let fileUpload: FileUpload = databaseClient.fetch().first!
        XCTAssertFalse(fileUpload.completed)
        XCTAssertEqual(fileUpload.error, "upload failed")
        XCTAssert(eventHandler.didFinishEvent)
    }

    func testURLSessionDidFinishEvents() {
        model.urlSessionDidFinishEvents(forBackgroundURLSession: session)
        XCTAssert(eventHandler.didFinishEvents)
    }

    func startFileUpload() {
        let assignment = Assignment.make()
        let fileInfo = FileInfo(url: testFile, size: 2048)
        let context = ContextModel(.course, id: "1")
        let prepare = QueueFileUpload(fileInfo: fileInfo, context: context, assignmentID: assignment.id, userID: "1", env: environment)
        addOperationAndWait(prepare)
        let start = StartFileUpload(backgroundSessionID: backgroundSessionID, task: task, database: database, url: testFile)
        addOperationAndWait(start)
    }
}
