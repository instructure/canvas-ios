//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import TestsFoundation

class InboxTests: CanvasUITests {
    func testCannotMessageEntireClassWhenDisabled() {
        TabBar.inboxTab.tap()
        Inbox.newMessageButton.tap()

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
        Inbox.newMessageButton.tap()

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
        XCTAssert(TabBar.inboxTab.value == "2 items")
        TabBar.inboxTab.tap()

        Inbox.message(id: "47").waitToExist()
        Inbox.filterButton.tap()
        Inbox.filterOption("Assignment").waitToExist()
        Inbox.filterOption("Assignment").tap()
        Inbox.message(id: "47").waitToVanish()
        XCTAssert(Inbox.message(id: "48").isVisible)
    }
}
