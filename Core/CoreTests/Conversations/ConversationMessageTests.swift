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
            ), ]
        ))
        XCTAssertEqual(message.mediaComment?.mediaID, "m-1234567890")
        XCTAssertEqual(message.attachments.first?.id, "1")
        XCTAssertEqual(message.forwarded.first?.id, "2")

        XCTAssertNil(ConversationMessage.make().mediaComment)
        XCTAssert(ConversationMessage.make().attachments.isEmpty)
        XCTAssert(ConversationMessage.make().forwarded.isEmpty)
    }
}
