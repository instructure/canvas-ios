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

        testee = ComposeMessageInteractorLive(env: environment, publisherProvider: URLSessionDataTaskPublisherProviderMock())

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

    func testDeleteFile() {
        let fileId = "1"
        let deleteRequest = DeleteFileRequest(fileID: fileId)
        let response = APIFile.make()
        api.mock(deleteRequest, value: response)

        XCTAssertFinish(testee.deleteFile(file: File.make(from: response)))

        waitForState(.data)
    }

    func testOnlineFileURLGetter() {
        var subscriptions: [AnyCancellable] = []
        let expectation = self.expectation(description: "getURL")
        var resultURL: URL?
        let fileId = "1"
        let getRequest = GetFileRequest(context: .currentUser, fileID: fileId, include: [])
        let response = APIFile.make(url: URL(string: "https://instructure.com/test.txt")!)
        api.mock(getRequest, value: response)

        testee.getOnlineFileURL(fileId: fileId)
            .sink(receiveCompletion: { _ in }, receiveValue: { url in
                resultURL = url
                expectation.fulfill()
            })
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(resultURL, URL.Directories.documents.appendingPathComponent("testOverwritten.txt"))
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
    }

    private func waitForState(_ state: StoreState) {
        let stateUpdate = expectation(description: "Expected state reached")
        stateUpdate.assertForOverFulfill = false
        stateUpdate.fulfill()
        wait(for: [stateUpdate], timeout: 1)
    }

    class URLSessionDataTaskPublisherProviderMock: URLSessionDataTaskPublisherProvider {
        let savedURL = URL.Directories.documents.appendingPathComponent("test.txt")

        func getPublisher(for request: URLRequest) -> AnyPublisher<(tempURL: URL, fileName: String), Error> {
            return Just((tempURL: savedURL, fileName: "testOverwritten.txt"))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
