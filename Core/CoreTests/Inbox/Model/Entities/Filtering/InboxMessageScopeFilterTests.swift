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

class InboxMessageScopeFilterTests: CoreTestCase {
    private var readMessage: InboxMessageListItem!
    private var unreadMessage: InboxMessageListItem!
    private var archivedMessage: InboxMessageListItem!
    private var starredReadMessage: InboxMessageListItem!
    private var sentReadMessage: InboxMessageListItem!

    override public func setUp() {
        super.setUp()

        readMessage = databaseClient.insert() as InboxMessageListItem
        readMessage.messageId = "1"
        readMessage.state = .read
        unreadMessage = databaseClient.insert() as InboxMessageListItem
        unreadMessage.messageId = "2"
        unreadMessage.state = .unread
        archivedMessage = databaseClient.insert() as InboxMessageListItem
        archivedMessage.messageId = "3"
        archivedMessage.state = .archived
        starredReadMessage = databaseClient.insert() as InboxMessageListItem
        starredReadMessage.messageId = "4"
        starredReadMessage.state = .read
        starredReadMessage.isStarred = true
        sentReadMessage = databaseClient.insert() as InboxMessageListItem
        sentReadMessage.messageId = "5"
        sentReadMessage.state = .read
        sentReadMessage.isSent = true
    }

    func testMessageFilterAll() {
        let messageIds = messageIds(for: .all)
        XCTAssertEqual(messageIds, Set([readMessage.messageId,
                                        unreadMessage.messageId,
                                        starredReadMessage.messageId,
                                       ]))
    }

    func testMessageFilterUnread() {
        let messageIds = messageIds(for: .unread)
        XCTAssertEqual(messageIds, Set([unreadMessage.messageId]))
    }

    func testMessageFilterArchived() {
        let messageIds = messageIds(for: .archived)
        XCTAssertEqual(messageIds, Set([archivedMessage.messageId]))
    }

    func testMessageFilterSent() {
        let messageIds = messageIds(for: .sent)
        XCTAssertEqual(messageIds, Set([sentReadMessage.messageId]))
    }

    func testMessageFilterStarred() {
        let messageIds = messageIds(for: .starred)
        XCTAssertEqual(messageIds, Set([starredReadMessage.messageId]))
    }

    private func messageIds(for scope: InboxMessageScope) -> Set<String> {
        let scope = Scope(predicate: scope.messageFilter, order: [])
        let messages: [InboxMessageListItem] = databaseClient.fetch(scope: scope)
        let messageIds = Set(messages.map { $0.messageId })
        return messageIds
    }
}
