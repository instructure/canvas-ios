//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
@testable import Core
import XCTest

class ComposeMessageOptionsTests: CoreTestCase {
    func testNewMessageOptions() {
        let options: ComposeMessageOptions = .init(fromType: .new)

        let disabledFields = options.disabledFields
        XCTAssertFalse(disabledFields.contextDisabled)
        XCTAssertFalse(disabledFields.subjectDisabled)
        XCTAssertFalse(disabledFields.messageDisabled)
        XCTAssertFalse(disabledFields.recipientsDisabled)

        let fieldContents = options.fieldContents
        XCTAssertEqual(fieldContents.subjectText, "")
        XCTAssertEqual(fieldContents.bodyText, "")
        XCTAssertEqual(fieldContents.selectedRecipients, [])
        XCTAssertNil(fieldContents.selectedContext)

        XCTAssertEqual(options.messageType, .new)

    }

    func testReplyMessageOptions() {
        let conversation: Conversation = .make()
        let message: ConversationMessage = .make()
        let options: ComposeMessageOptions = .init(fromType: .reply(conversation: conversation, message: message))

        let disabledFields = options.disabledFields
        XCTAssertTrue(disabledFields.contextDisabled)
        XCTAssertTrue(disabledFields.subjectDisabled)
        XCTAssertFalse(disabledFields.messageDisabled)
        XCTAssertFalse(disabledFields.recipientsDisabled)

        let fieldContents = options.fieldContents
        XCTAssertEqual(fieldContents.subjectText, conversation.subject)
        XCTAssertEqual(fieldContents.bodyText, "")
        XCTAssertEqual(fieldContents.selectedRecipients.first?.ids.first, message.authorID)
        XCTAssertEqual(fieldContents.selectedContext?.context.canvasContextID, conversation.contextCode)

        XCTAssertEqual(options.messageType, .reply(conversation: conversation, message: message))
    }

    func testReplyAllMessageOptions() {
        let conversation: Conversation = .make()
        let message: ConversationMessage = .make()
        let options: ComposeMessageOptions = .init(fromType: .replyAll(conversation: conversation, message: message))

        let disabledFields = options.disabledFields
        XCTAssertTrue(disabledFields.contextDisabled)
        XCTAssertTrue(disabledFields.subjectDisabled)
        XCTAssertFalse(disabledFields.messageDisabled)
        XCTAssertFalse(disabledFields.recipientsDisabled)

        let fieldContents = options.fieldContents
        XCTAssertEqual(fieldContents.subjectText, conversation.subject)
        XCTAssertEqual(fieldContents.bodyText, "")
        XCTAssertEqual(fieldContents.selectedRecipients, conversation.audience.map { Recipient(conversationParticipant: $0) })
        XCTAssertEqual(fieldContents.selectedContext?.context.canvasContextID, conversation.contextCode)

        XCTAssertEqual(options.messageType, .replyAll(conversation: conversation, message: message))
    }

    func testForwardOptions() {
        let conversation: Conversation = .make()
        let message: ConversationMessage = .make()
        let options: ComposeMessageOptions = .init(fromType: .forward(conversation: conversation, message: message))

        let disabledFields = options.disabledFields
        XCTAssertTrue(disabledFields.contextDisabled)
        XCTAssertTrue(disabledFields.subjectDisabled)
        XCTAssertFalse(disabledFields.messageDisabled)
        XCTAssertFalse(disabledFields.recipientsDisabled)

        let fieldContents = options.fieldContents
        XCTAssertEqual(fieldContents.subjectText, "Fw: \(conversation.subject)")
        XCTAssertEqual(fieldContents.bodyText, "")
        XCTAssertEqual(fieldContents.selectedRecipients, [] )
        XCTAssertEqual(fieldContents.selectedContext?.context.canvasContextID, conversation.contextCode)

        XCTAssertEqual(options.messageType, .forward(conversation: conversation, message: message))
    }
}
