//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class MessagesE2ETest: CoreUITestCase {
    func testMessagesE2ETest() {
        DashboardHelper.courseCard(courseId: "263").hit()
        DashboardHelper.TabBar.inboxTab.hit()
        XCTAssertTrue(InboxHelper.newMessageButton.waitUntil(.visible).isVisible)
        XCTAssertTrue(InboxHelper.Filter.byCourse.waitUntil(.visible).isVisible)
        XCTAssertTrue(InboxHelper.conversation(conversationId: "320").waitUntil(.visible).isVisible)
        XCTAssertTrue(app.find(labelContaining: "We need to talk about Student One").waitUntil(.visible).isVisible)
        InboxHelper.newMessageButton.hit()
        InboxHelper.Composer.courseSelectButton.hit()
        InboxHelper.Composer.courseSelectionItem(courseId: "263").hit()
        InboxHelper.Composer.addRecipientButton.hit()
        InboxHelper.Composer.recipientSelectionItem(courseId: "263").hit()
        XCTAssertTrue(InboxHelper.Composer.subjectInput.waitUntil(.visible).isVisible)
        XCTAssertTrue(InboxHelper.Composer.attachButton.waitUntil(.visible).isVisible)
        InboxHelper.Composer.attachButton.hit()
        XCTAssertTrue(InboxHelper.Composer.Attachments.addButton.waitUntil(.visible).isVisible)
        InboxHelper.Composer.Attachments.dismissButton.hit()
        InboxHelper.Composer.cancelButton.hit()
    }
}
