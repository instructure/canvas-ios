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

import TestsFoundation

class InboxTests: CoreUITestCase {
    typealias Helper = InboxHelperParent

    func testGetToReplyScreen() {
        DashboardHelper.profileButton.hit()
        ProfileHelper.inboxButton.hit()
        let conversationElement = Helper.conversation(conversationId: "320").waitUntil(.visible)
        let label = conversationElement.label
        XCTAssert(label.contains("Assignments"))
        XCTAssert(label.contains("need to talk"))
        XCTAssert(label.contains("last message was on Jan"))
        XCTAssert(label.contains("Yeah, whatever"))

        conversationElement.hit()
        Helper.replyButton.hit()
        let messageInput = Helper.Reply.body.waitUntil(.visible)
        XCTAssertTrue(messageInput.isVisible)
    }
}
