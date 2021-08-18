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

import XCTest
import TestsFoundation

class MessagesE2ETest: CoreUITestCase {
    func testMessagesE2ETest() {
        Dashboard.courseCard(id: "263").waitToExist()
        TabBar.inboxTab.tap()
        Inbox.newMessageButton.waitToExist()
        Inbox.filterButton.waitToExist()
        Inbox.message(id: "320").waitToExist()
        app.find(labelContaining: "We need to talk about Student One").waitToExist()
        Inbox.newMessageButton.tap()
        NewMessage.selectCourseButton.waitToExist()
        NewMessage.selectCourseButton.tap()
        MessageCourseSelection.course(id: "263").waitToExist()
        MessageCourseSelection.course(id: "263").tap()
        NewMessage.addRecipientButton.tap()
        MessageRecipientsSelection.messageAllInCourse(courseID: "263").tap()
        NewMessage.subjectTextView.waitToExist()
        NewMessage.attachButton.waitToExist()
        NewMessage.attachButton.tap()
        Attachments.addButton.waitToExist()
        Attachments.dismissButton.tap()
        NewMessage.cancelButton.tap()
    }
}
