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

        testee = ComposeMessageInteractorLive()

        waitForState(.data)
    }

    func testFailedSend() {
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

        XCTAssertFailure(testee.send(parameters: parameters))
    }

    func testSuccessfulSend() {
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

        XCTAssertFinish(testee.send(parameters: parameters))

        waitForState(.data)
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
}
