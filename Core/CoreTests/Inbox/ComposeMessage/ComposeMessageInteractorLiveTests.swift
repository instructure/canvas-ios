//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Combine
@testable import Core
import XCTest

class ComposeMessageInteractorLiveTests: CoreTestCase {
    private var testee: ComposeMessageInteractorLive!

    override func setUp() {
        super.setUp()
        mockData()

        testee = ComposeMessageInteractorLive(batchId: "testId", uploadFolderPath: "", uploadManager: uploadManager)

        waitForState(.data)
    }

    func testFailedCreate() {
        let subject = "Test subject"
        let body = "Test body"
        let recipients = ["1", "2"]
        let canvasContext = "1"
        let attachments: [String]? = nil
        let createConversationRequest = CreateConversation(
            subject: subject,
            body: body,
            recipientIDs: recipients,
            canvasContextID: canvasContext,
            attachmentIDs: attachments
        ).request

        let parameters = MessageParameters(subject: subject, body: body, recipientIDs: recipients, context: Context.course(canvasContext))
        api.mock(createConversationRequest, value: nil, response: nil, error: NSError.instructureError("Failure"))

        XCTAssertFailure(testee.createConversation(parameters: parameters))
    }

    func testSuccessfulCreate() {
        let subject = "Test subject"
        let body = "Test body"
        let recipients = ["1", "2"]
        let canvasContext = "1"
        let attachments: [String]? = nil
        let createConversationRequest = CreateConversation(
            subject: subject,
            body: body,
            recipientIDs: recipients,
            canvasContextID: canvasContext,
            attachmentIDs: attachments
        ).request
        let value = [APIConversation.make(id: "1")]
        let parameters = MessageParameters(subject: subject, body: body, recipientIDs: recipients, context: Context.course(canvasContext))
        api.mock(createConversationRequest, value: value)

        XCTAssertFinish(testee.createConversation(parameters: parameters))

        waitForState(.data)
    }

    func testFailedMessageAdd() {
        let subject = "Test subject"
        let body = "Test body"
        let recipients = ["1", "2"]
        let canvasContext = "1"
        let conversation = "1"
        let attachments: [String]? = nil
        let includedMessages = ["1"]
        let addConversationMessageRequest = AddMessage(
            conversationID: canvasContext,
            attachmentIDs: attachments,
            body: body,
            recipientIDs: recipients,
            includedMessages: includedMessages
        ).request
        let parameters = MessageParameters(
            subject: subject,
            body: body,
            recipientIDs: recipients,
            context: Context.course(canvasContext),
            conversationID: conversation,
            includedMessages: includedMessages
        )
        api.mock(addConversationMessageRequest, value: nil, response: nil, error: NSError.instructureError("Failure"))

        XCTAssertFailure(testee.addConversationMessage(parameters: parameters))
    }

    func testSuccessfulMessageAdd() {
        let subject = "Test subject"
        let body = "Test body"
        let recipients = ["1", "2"]
        let canvasContext = "1"
        let conversation = "1"
        let attachments: [String]? = nil
        let includedMessages = ["1"]
        let addConversationMessageRequest = AddMessage(
            conversationID: canvasContext,
            attachmentIDs: attachments,
            body: body,
            recipientIDs: recipients,
            includedMessages: includedMessages
        ).request
        let value = APIConversation.make(id: "1")
        let parameters = MessageParameters(
            subject: subject,
            body: body,
            recipientIDs: recipients,
            context: Context.course(canvasContext),
            conversationID: conversation,
            includedMessages: includedMessages
        )
        api.mock(addConversationMessageRequest, value: value)

        XCTAssertFinish(testee.addConversationMessage(parameters: parameters))

        waitForState(.data)
    }

    func testAddFileWithURL() {
        XCTAssertFalse(uploadManager.addWasCalled)
        XCTAssertFalse(uploadManager.uploadWasCalled)

        let url = URL.Directories.temporary.appendingPathComponent("upload-manager-add-test.txt")
        FileManager.default.createFile(atPath: url.path, contents: "hello".data(using: .utf8), attributes: nil)
        testee.addFile(url: url)

        XCTAssertTrue(uploadManager.addWasCalled)
        XCTAssertTrue(uploadManager.uploadWasCalled)
    }

    func testFailedToAddFileWithURL() {
        XCTAssertFalse(uploadManager.addWasCalled)
        XCTAssertFalse(uploadManager.uploadWasCalled)

        let url = URL(string: "https://instructure.com")!
        testee.addFile(url: url)

        XCTAssertTrue(uploadManager.addWasCalled)
        XCTAssertFalse(uploadManager.uploadWasCalled)
    }

    func testAddFileFromUserFilesWithoutDuplicate() {
        var subscriptions: [AnyCancellable] = []
        let file = File.make(from: APIFile.make(folder_id: "1"))
        var attachments: [File] = []
        let exp = expectation(description: "fileAdded")
        testee.attachments.sink { files in
            attachments = files
            if !attachments.isEmpty { exp.fulfill() }
        }
        .store(in: &subscriptions)

        testee.addFile(file: file)
        wait(for: [exp], timeout: 5)

        XCTAssertTrue(attachments.contains(file))
    }

    func testAddFileFromUserFilesWithDuplicate() {
        var subscriptions: [AnyCancellable] = []
        let path = ""
        testee = ComposeMessageInteractorLive(batchId: "testId", uploadFolderPath: path, restrictForFolderPath: true, uploadManager: uploadManager)
        let rootFolderRequest = GetContextFolderHierarchyRequest(context: .currentUser, fullPath: path)
        let rootFolderResponse = [APIFolder.make(id: "1")]
        api.mock(rootFolderRequest, value: rootFolderResponse)
        let uploadFolderRequest = GetFolderByPath(context: .currentUser, path: path)
        let uploadFolderResponse = [APIFolder.make(id: "1")]
        api.mock(uploadFolderRequest, value: uploadFolderResponse)

        let file = File.make(from: APIFile.make(id: "1", folder_id: "3"))
        var attachments: [File] = []
        let exp = expectation(description: "fileAdded")
        testee.attachments.sink { files in
            attachments = files
            if !attachments.isEmpty { exp.fulfill() }
        }
        .store(in: &subscriptions)
        testee.addFile(file: file)
        wait(for: [exp], timeout: 5)

        XCTAssertTrue(attachments.contains(file))
    }

    func testRetry() {
        XCTAssertFalse(uploadManager.addWasCalled)
        XCTAssertFalse(uploadManager.uploadWasCalled)

        let url = URL.Directories.temporary.appendingPathComponent("upload-manager-add-test.txt")
        FileManager.default.createFile(atPath: url.path, contents: "hello".data(using: .utf8), attributes: nil)
        testee.addFile(url: url)
        uploadManager.uploadWasCalled = false

        testee.retry()

        XCTAssertTrue(uploadManager.uploadWasCalled)

    }

    func testCancel() {
        var subscriptions: [AnyCancellable] = []
        var attachments: [File] = []
        let fileAddedExp = expectation(description: "fileAdded")
        let fileRemovedExp = expectation(description: "fileRemoved")
        var fileAddedFlag = false

        let file = File.make(from: APIFile.make(folder_id: "1"))
        testee.attachments.sink { files in
            attachments = files
            if !attachments.isEmpty { fileAddedFlag = true; fileAddedExp.fulfill() }
            if attachments.isEmpty && fileAddedFlag {  fileRemovedExp.fulfill() }
        }
        .store(in: &subscriptions)
        testee.addFile(file: file)

        wait(for: [fileAddedExp], timeout: 5)
        XCTAssertTrue(attachments.contains(file))

        testee.cancel()

        wait(for: [fileRemovedExp], timeout: 5)
        XCTAssertFalse(attachments.contains(file))
    }

    func testRemoveAlreadyUploadedFile() {
        var subscriptions: [AnyCancellable] = []
        var attachments: [File] = []
        let fileAddedExp = expectation(description: "fileAdded")
        let fileRemovedExp = expectation(description: "fileRemoved")
        var fileAddedFlag = false

        let file = File.make(from: APIFile.make(folder_id: "1"))
        testee.attachments.sink { files in
            attachments = files
            if !attachments.isEmpty && !fileAddedExp { fileAddedFlag = true; fileAddedExp.fulfill() }
            if attachments.isEmpty && fileAddedFlag && !fileRemovedExp {  fileRemovedExp.fulfill() }
        }
        .store(in: &subscriptions)

        testee.addFile(file: file)
        wait(for: [fileAddedExp], timeout: 5)
        XCTAssertTrue(attachments.contains(file))

        testee.removeFile(file: file)
        wait(for: [fileRemovedExp], timeout: 5)
        XCTAssertFalse(attachments.contains(file))
    }

    func testRemoveAndDeleteUploadedFile() {
        var subscriptions: [AnyCancellable] = []
        var attachments: [File] = []
        let fileAddedExp = expectation(description: "fileAdded")
        let fileRemovedExp = expectation(description: "fileRemoved")
        var fileAddedFlag = false
        var fileRemovedFlag = false
        var file: File?
        let deleteRequest = DeleteFileRequest(fileID: "1")
        let deleteResponse = APIFile.make()
        api.mock(deleteRequest, value: deleteResponse)

        let url = URL.Directories.temporary.appendingPathComponent("upload-manager-add-test.txt")
        FileManager.default.createFile(atPath: url.path, contents: "hello".data(using: .utf8), attributes: nil)
        testee.attachments.sink { files in
            attachments = files
            if !attachments.isEmpty && !fileAddedFlag {
                fileAddedFlag = true
                fileAddedExp.fulfill()
                file = files.first
            }
            if attachments.isEmpty && fileAddedFlag && !fileRemovedFlag {
                fileRemovedFlag = true
                fileRemovedExp.fulfill()
            }
        }
        .store(in: &subscriptions)

        testee.addFile(url: url)
        wait(for: [fileAddedExp], timeout: 5)
        XCTAssertTrue(attachments.contains(file!))
        file?.id = "1"

        testee.removeFile(file: file!)
        wait(for: [fileRemovedExp], timeout: 5)
        XCTAssertFalse(attachments.contains(file!))
    }

    private func mockData() {
        let course1 = APICourse.make(
            id: "1",
            name: "Course 1"
        )
        let course2 = APICourse.make(
            id: "2",
            name: "Course 2"
        )
        let courses = [course1, course2]

        api.mock(GetInboxCourseList(), value: courses)

        let uploadFolderRequest = GetFolderByPath(context: .currentUser, path: "")
        let uploadFolderResponse = [APIFolder.make(id: "1")]
        api.mock(uploadFolderRequest, value: uploadFolderResponse)
    }

    private func waitForState(_ state: StoreState) {
        let stateUpdate = expectation(description: "Expected state reached")
        stateUpdate.assertForOverFulfill = false
        stateUpdate.fulfill()
        wait(for: [stateUpdate], timeout: 1)
    }

    private class URLSessionDataTaskPublisherProviderMock: URLSessionDataTaskPublisherProvider {
        let savedURL = URL.Directories.documents.appendingPathComponent("test.txt")

        func getPublisher(for request: URLRequest) -> AnyPublisher<(tempURL: URL, fileName: String), Error> {
            return Just((tempURL: savedURL, fileName: "testOverwritten.txt"))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
