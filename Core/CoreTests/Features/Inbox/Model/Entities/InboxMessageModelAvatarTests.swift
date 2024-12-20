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

@testable import Core
import XCTest

class InboxMessageModelAvatarTests: CoreTestCase {

    func testGroupInitializer() {
        let p1 = APIConversationParticipant.make()
        let p2 = APIConversationParticipant.make()
        XCTAssertEqual(InboxMessageAvatar(participants: [p1, p2]), .group)
    }

    func testIndividualInitializer() {
        let p = APIConversationParticipant.make(name: "Test Name", avatar_url: URL(string: "/test/url")!)
        XCTAssertEqual(InboxMessageAvatar(participants: [p]), .individual(name: "Test Name", profileImageURL: URL(string: "/test/url")!))
    }
}
