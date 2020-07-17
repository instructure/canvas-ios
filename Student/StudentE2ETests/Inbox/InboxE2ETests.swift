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
@testable import CoreUITests

class InboxE2ETests: CoreUITestCase {
    override var abstractTestClass: CoreUITestCase.Type { InboxE2ETests.self }

    func testCannotMessageEntireClassWhenDisabled() {
        TabBar.inboxTab.tap()
        Inbox.newMessageButton.tapUntil {
            NewMessage.selectCourseButton.exists
        }

        // Course Selection
        NewMessage.selectCourseButton.tap()
        MessageCourseSelection.course(id: "263").tap()
        NewMessage.addRecipientButton.tap()

        // Recipients Selection
        MessageRecipientsSelection.studentsInCourse(courseID: "263").waitToExist()
        XCTAssertFalse(MessageRecipientsSelection.messageAllInCourse(courseID: "263").isVisible)
        MessageRecipientsSelection.studentsInCourse(courseID: "263").tap()
        XCTAssertFalse(MessageRecipientsSelection.messageAllStudents(courseID: "263").isVisible)
    }

    func testCannotMessageIndividialsWhenDisabled() {
        TabBar.inboxTab.tap()
        Inbox.newMessageButton.tapUntil {
            NewMessage.selectCourseButton.exists
        }

        // Course Selection
        NewMessage.selectCourseButton.tap()
        MessageCourseSelection.course(id: "263").tap()
        NewMessage.addRecipientButton.tap()

        // Recipients Selection
        MessageRecipientsSelection.studentsInCourse(courseID: "263").waitToExist()
        MessageRecipientsSelection.studentsInCourse(courseID: "263").tap()
        MessageRecipientsSelection.student(studentID: "613").waitToExist()
        XCTAssertFalse(MessageRecipientsSelection.student(studentID: "651").exists)
    }

    func testCanFilterMessagesAndShowsUnread() {
        XCTAssert(TabBar.inboxTab.value() == "2 items")
        TabBar.inboxTab.tap()

        Inbox.message(id: "47").waitToExist()
        Inbox.filterButton.tap()
        Inbox.filterOption("Assignment").waitToExist()
        Inbox.filterOption("Assignment").tap()
        Inbox.message(id: "47").waitToVanish()
        XCTAssert(Inbox.message(id: "48").isVisible)
    }
}
