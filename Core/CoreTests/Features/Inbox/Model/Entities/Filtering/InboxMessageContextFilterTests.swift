//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import XCTest

class InboxMessageContextFilterTests: CoreTestCase {
    private var noCourseMessage: InboxMessageListItem!
    private var course1Message: InboxMessageListItem!
    private var course2Message: InboxMessageListItem!

    override public func setUp() {
        super.setUp()

        noCourseMessage = databaseClient.insert() as InboxMessageListItem
        noCourseMessage.messageId = "1"
        noCourseMessage.contextFilter = nil

        course1Message = databaseClient.insert() as InboxMessageListItem
        course1Message.messageId = "2"
        course1Message.contextFilter = "course_1"

        course2Message = databaseClient.insert() as InboxMessageListItem
        course2Message.messageId = "3"
        course2Message.contextFilter = "course_2"
    }

    func testContextFilterAll() {
        let context: Context? = nil
        let scope = Scope(predicate: context.inboxMessageFilter, order: [])
        let messages: [InboxMessageListItem] = databaseClient.fetch(scope: scope)
        let messageIds = Set(messages.map { $0.messageId })
        XCTAssertEqual(messageIds, Set(["1"]))
    }

    func testContextFilterCourse1() {
        let context: Context? = Context(.course, id: "1")
        let scope = Scope(predicate: context.inboxMessageFilter, order: [])
        let messages: [InboxMessageListItem] = databaseClient.fetch(scope: scope)
        let messageIds = Set(messages.map { $0.messageId })
        XCTAssertEqual(messageIds, Set(["2"]))
    }
}
