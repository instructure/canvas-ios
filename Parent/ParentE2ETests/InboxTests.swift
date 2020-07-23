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

import Core
import TestsFoundation

class InboxTests: CoreUITestCase {
    func testGetToReplyScreen() {
        Dashboard.profileButton.tap()
        Profile.inboxButton.tap()
        let label = ConversationList.cell(id: "320").label()
        XCTAssert(label.contains("Assignments"))
        XCTAssert(label.contains("need to talk"))
        XCTAssert(label.contains("last message was on Jan"))
        XCTAssert(label.contains("Yeah, whatever"))
        ConversationList.cell(id: "320").waitToExist().tap()
        ConversationDetail.replyButton.tapUntil {
            ComposeReply.body.exists()
        }
    }
}
