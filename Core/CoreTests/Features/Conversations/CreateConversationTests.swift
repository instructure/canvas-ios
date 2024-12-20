//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import XCTest
@testable import Core

class CreateConversationTests: CoreTestCase {
    func testUseCase() {
        let useCase = CreateConversation(
            subject: "subject",
            body: "body",
            recipientIDs: ["1"],
            canvasContextID: "course_1",
            mediaCommentID: "1",
            mediaCommentType: .audio,
            attachmentIDs: ["1"]
        )
        XCTAssertEqual(useCase.request.body?.subject, "subject")
        XCTAssertEqual(useCase.request.body?.body, "body")
        XCTAssertEqual(useCase.request.body?.recipients, ["1"])
        XCTAssertEqual(useCase.request.body?.context_code, "course_1")
        XCTAssertEqual(useCase.request.body?.media_comment_id, "1")
        XCTAssertEqual(useCase.request.body?.media_comment_type, .audio)
        XCTAssertEqual(useCase.request.body?.attachment_ids, ["1"])
    }

    func testWritesData() {
        let useCase = CreateConversation(subject: "subject", body: "body", recipientIDs: ["1"])
        api.mock(useCase.request, value: [APIConversation.make(subject: "subject", context_name: nil, context_code: nil)])

        useCase.fetch()
        let conversation: Conversation = databaseClient.fetch().first!
        XCTAssertNotNil(conversation)
        XCTAssertEqual(conversation.subject, "subject")
        XCTAssertNil(conversation.contextCode)
        XCTAssertNil(conversation.contextName)
    }

    func testWritesContextName() {
        let course = Course.make()
        let useCase = CreateConversation(subject: "subject", body: "body", recipientIDs: ["1"], canvasContextID: course.canvasContextID)
        api.mock(useCase.request, value: [APIConversation.make(context_name: nil)])

        useCase.fetch()
        let conversation: Conversation = databaseClient.fetch().first!
        XCTAssertEqual(conversation.contextCode, course.canvasContextID)
        XCTAssertEqual(conversation.contextName, course.name)
    }

    func test_groupConversationIsTrue() {
        let useCase = CreateConversation(
            subject: "subject",
            body: "body",
            recipientIDs: ["1"],
            canvasContextID: "course_1",
            mediaCommentID: "1",
            mediaCommentType: .audio,
            attachmentIDs: ["1"]
        )
        let groupConversation = useCase.request.body?.group_conversation ?? false
        XCTAssertTrue(groupConversation)
    }
}
