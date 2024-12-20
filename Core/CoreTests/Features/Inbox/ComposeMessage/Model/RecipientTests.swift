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

import Foundation

@testable import Core
import XCTest

class RecipientTests: CoreTestCase {

    let id = "1"
    let ids = ["1", "2"]
    let displayName = "Test Name"
    let avatarURL = URL(string: "https://test.com")
    let searchRecipient = SearchRecipient.make()
    let conversationParticipant = ConversationParticipant.make()

    func testBaseConstructor() {
        let testee = Recipient(id: id, name: displayName, avatarURL: avatarURL)
        XCTAssertEqual(testee.ids, [id])
        XCTAssertEqual(testee.displayName, displayName)
        XCTAssertEqual(testee.avatarURL, avatarURL)
    }

    func testBaseArrayConstructor() {
        let testee = Recipient(ids: ids, name: displayName, avatarURL: avatarURL)
        XCTAssertEqual(testee.ids, ids)
        XCTAssertEqual(testee.displayName, displayName)
        XCTAssertEqual(testee.avatarURL, avatarURL)
    }

    func testSearchRecipientConstructor() {
        let testee = Recipient(searchRecipient: searchRecipient)
        XCTAssertEqual(testee.ids, [searchRecipient.id])
        XCTAssertEqual(testee.displayName, searchRecipient.name)
        XCTAssertEqual(testee.avatarURL, searchRecipient.avatarURL)
    }

    func testSearchRecipientArrayConstructor() {
        let testee = Recipient(searchRecipients: [searchRecipient], displayName: "Test name")
        XCTAssertEqual(testee.ids, [searchRecipient.id])
        XCTAssertEqual(testee.displayName, "Test name")
        XCTAssertEqual(testee.avatarURL, searchRecipient.avatarURL)
    }

    func testConversationParticipantConstructor() {
        let testee = Recipient(conversationParticipant: conversationParticipant)
        XCTAssertEqual(testee.ids, [conversationParticipant.id])
        XCTAssertEqual(testee.displayName, conversationParticipant.name)
        XCTAssertEqual(testee.avatarURL, conversationParticipant.avatarURL)
    }

    func testConversationParticipantArrayConstructor() {
        let testee = Recipient(conversationParticipants: [conversationParticipant], displayName: "Test name")
        XCTAssertEqual(testee.ids, [conversationParticipant.id])
        XCTAssertEqual(testee.displayName, "Test name")
        XCTAssertEqual(testee.avatarURL, conversationParticipant.avatarURL)
    }
}
