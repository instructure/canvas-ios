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

import XCTest
@testable import Core
import TestsFoundation

class ConversationMessageTests: CoreTestCase {
    func testProperties() {
        let message = ConversationMessage.make(from: .make(
            media_comment: .make(),
            attachments: [.make()],
            forwarded_messages: [ .make(
                id: "2"
            ) ]
        ))
        XCTAssertEqual(message.mediaComment?.mediaID, "m-1234567890")
        XCTAssertEqual(message.attachments.first?.id, "1")
        XCTAssertEqual(message.forwarded.first?.id, "2")

        XCTAssertNil(ConversationMessage.make().mediaComment)
        XCTAssert(ConversationMessage.make().attachments.isEmpty)
        XCTAssert(ConversationMessage.make().forwarded.isEmpty)
    }

    func testLocalizedAudienceWithWithMeAnd1Recipient() {
        let userMap = [
            "1": ConversationParticipant.make( from: .make(id: "1", name: "User One") ),
            "2": ConversationParticipant.make( from: .make(id: "2", name: "User Two") )
        ]
        let myID = "1"

        let message = ConversationMessage.make(from: .make( author_id: "2", participating_user_ids: ["1", "2"] ) )

        let text = message.localizedAudience(myID: myID, userMap: userMap)
        XCTAssertEqual(text, "to me")
    }

    func testLocalizedAudienceWithWithMeAnd2Recipients() {
        let userMap = [
            "1": ConversationParticipant.make( from: .make(id: "1", name: "User 1") ),
            "2": ConversationParticipant.make( from: .make(id: "2", name: "User 2") ),
            "3": ConversationParticipant.make( from: .make(id: "3", name: "User 3") )
        ]
        let myID = "1"

        let message = ConversationMessage.make(from: .make( author_id: "2", participating_user_ids: ["1", "2", "3"] ) )

        let text = message.localizedAudience(myID: myID, userMap: userMap)
        XCTAssertEqual(text, "to me & 1 other")
    }

    func testLocalizedAudienceWithWithMeAnd3Recipients() {
        let userMap = [
            "1": ConversationParticipant.make( from: .make(id: "1", name: "User 1") ),
            "2": ConversationParticipant.make( from: .make(id: "2", name: "User 2") ),
            "3": ConversationParticipant.make( from: .make(id: "3", name: "User 3") ),
            "4": ConversationParticipant.make( from: .make(id: "4", name: "User 4") )
        ]
        let myID = "1"

        let message = ConversationMessage.make(from: .make( author_id: "2", participating_user_ids: ["1", "2", "3", "4"] ) )

        let text = message.localizedAudience(myID: myID, userMap: userMap)
        XCTAssertEqual(text, "to me & 2 others")
    }

    func testLocalizedAudienceWithWith3Recipients() {
        let userMap = [
            "1": ConversationParticipant.make( from: .make(id: "1", name: "User 1") ),
            "2": ConversationParticipant.make( from: .make(id: "2", name: "User 2") ),
            "3": ConversationParticipant.make( from: .make(id: "3", name: "User 3") ),
            "4": ConversationParticipant.make( from: .make(id: "4", name: "User 4") )
        ]
        let myID = "1"

        let message = ConversationMessage.make(from: .make( author_id: "1", participating_user_ids: ["1", "2", "3", "4"] ) )

        let text = message.localizedAudience(myID: myID, userMap: userMap)
        XCTAssertEqual(text, "to 3 others")
    }
}
