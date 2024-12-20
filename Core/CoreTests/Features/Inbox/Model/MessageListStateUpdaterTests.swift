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

class MessageListStateUpdaterTests: CoreTestCase {
    private let testee = MessageListStateUpdater()

    // MARK: - Message Removal

    // MARK: Moving To/From Archive

    func testMessageInAllScopeGetsRemovedOnArchive() {
        let message = makeMessage(scopeFilter: .inbox)
        testee.update(message: message, newState: .archived)
        XCTAssertTrue(databaseClient.registeredObjects.isEmpty)
    }

    func testMessageInUnreadScopeGetsRemovedOnArchive() {
        let message = makeMessage(scopeFilter: .unread)
        testee.update(message: message, newState: .archived)
        XCTAssertTrue(databaseClient.registeredObjects.isEmpty)
    }

    func testMessageInStarredScopeGetsRemovedOnArchive() {
        let message = makeMessage(scopeFilter: .starred)
        testee.update(message: message, newState: .archived)
        XCTAssertTrue(databaseClient.registeredObjects.isEmpty)
    }

    func testMessageInSentScopeGetsRemovedOnArchive() {
        let message = makeMessage(scopeFilter: .sent)
        testee.update(message: message, newState: .archived)
        XCTAssertTrue(databaseClient.registeredObjects.isEmpty)
    }

    func testMessageInArchivedScopeGetsRemovedOnMakeRead() {
        let message = makeMessage(scopeFilter: .archived)
        testee.update(message: message, newState: .read)
        XCTAssertTrue(databaseClient.registeredObjects.isEmpty)
    }

    // MARK: In Unread Scope

    func testMarkingReadAnUnreadMessageDontRemoveItFromScope() {
        let message = makeMessage(scopeFilter: .unread)
        testee.update(message: message, newState: .read)
        XCTAssertEqual(databaseClient.registeredObjects.count, 1)
    }

    // MARK: - State Updates

    func testMessageWorkflowStateUpdates() {
        let message = makeMessage(scopeFilter: .inbox, messageState: .read)
        testee.update(message: message, newState: .unread)
        XCTAssertEqual(message.state, .unread)
    }

    private func makeMessage(scopeFilter: InboxMessageScope,
                             messageState: ConversationWorkflowState = .read)
    -> InboxMessageListItem {
        let message: InboxMessageListItem = databaseClient.insert()
        message.scopeFilter = scopeFilter.rawValue
        message.state = messageState
        try! databaseClient.save()
        XCTAssertEqual(databaseClient.registeredObjects.count, 1)
        return message
    }
}
