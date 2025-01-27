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
    private var starredMessage: InboxMessageListItem!
    private var sentMessage: InboxMessageListItem!

    override public func setUp() {
        super.setUp()

        readMessage = databaseClient.insert() as InboxMessageListItem
        readMessage.messageId = "1"
        readMessage.scopeFilter = InboxMessageScope.inbox.rawValue
        unreadMessage = databaseClient.insert() as InboxMessageListItem
        unreadMessage.messageId = "2"
        unreadMessage.scopeFilter = InboxMessageScope.unread.rawValue
        archivedMessage = databaseClient.insert() as InboxMessageListItem
        archivedMessage.messageId = "3"
        archivedMessage.scopeFilter = InboxMessageScope.archived.rawValue
        starredMessage = databaseClient.insert() as InboxMessageListItem
        starredMessage.messageId = "4"
        starredMessage.scopeFilter = InboxMessageScope.starred.rawValue
        sentMessage = databaseClient.insert() as InboxMessageListItem
        sentMessage.messageId = "5"
        sentMessage.scopeFilter = InboxMessageScope.sent.rawValue
    }

    func testMessageFilterAll() {
        let messageIds = messageIds(for: .inbox)
        XCTAssertEqual(messageIds, Set([readMessage.messageId]))
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
        XCTAssertEqual(messageIds, Set([sentMessage.messageId]))
    }

    func testMessageFilterStarred() {
        let messageIds = messageIds(for: .starred)
        XCTAssertEqual(messageIds, Set([starredMessage.messageId]))
    }

    private func messageIds(for scope: InboxMessageScope) -> Set<String> {
        let scope = Scope(predicate: scope.messageFilter, order: [])
        let messages: [InboxMessageListItem] = databaseClient.fetch(scope: scope)
        let messageIds = Set(messages.map { $0.messageId })
        return messageIds
    }
}
