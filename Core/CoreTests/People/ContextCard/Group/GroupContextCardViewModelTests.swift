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

import SwiftUI
@testable import Core
import TestsFoundation

class GroupContextCardViewModelTests: CoreTestCase {

    func testMessagingAllowed() {
        mockApiCalls(hasMessagePermission: true)
        let testee = GroupContextCardViewModel(groupID: "1", userID: "1", currentUserID: "0")
        testee.viewAppeared()

        XCTAssertTrue(testee.shouldShowMessageButton)
        testee.openNewMessageComposer(controller: UIViewController())
        XCTAssertTrue(router.lastRoutedTo("/conversations/compose"))
    }

    func testMessagingToSelfDisallowed() {
        mockApiCalls(hasMessagePermission: true)
        let testee = GroupContextCardViewModel(groupID: "1", userID: "1", currentUserID: "1")
        testee.viewAppeared()

        XCTAssertFalse(testee.shouldShowMessageButton)
        testee.openNewMessageComposer(controller: UIViewController())
        XCTAssertTrue(router.calls.isEmpty)
    }

    func testMessagingDisallowedWithoutPermissions() {
        mockApiCalls(hasMessagePermission: false)
        let testee = GroupContextCardViewModel(groupID: "1", userID: "1", currentUserID: "0")
        testee.viewAppeared()

        XCTAssertFalse(testee.shouldShowMessageButton)
        testee.openNewMessageComposer(controller: UIViewController())
        XCTAssertTrue(router.calls.isEmpty)
    }

    private func mockApiCalls(hasMessagePermission: Bool) {
        api.mock(GetContextPermissions(context: .group("1"), permissions: [.sendMessages]), value: .make(send_messages: hasMessagePermission))
        api.mock(GetGroup(groupID: "1"), value: .make())
        User.save(.make(), in: databaseClient)
    }
}
