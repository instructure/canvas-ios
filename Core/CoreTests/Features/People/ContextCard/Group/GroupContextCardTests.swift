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

import SwiftUI
@testable import Core
import TestsFoundation
import XCTest

class GroupContextCardTests: CoreTestCase {

    override func setUp() {
        super.setUp()
        mockApiCalls()
    }

    func testLayoutForSelfProfile() {
        let controller = hostSwiftUIController(GroupContextCardView(model: GroupContextCardViewModel(groupID: "1", userID: "1", currentUserID: "1")))
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "ContextCard.userNameLabel"))
        XCTAssertNotNil(tree?.find(id: "ContextCard.groupLabel"))
        XCTAssertNotNil(tree?.find(id: "Avatar.initialsLabel"))
    }

    private func mockApiCalls() {
        api.mock(GetGroup(groupID: "1"), value: .make())
        User.save(.make(), in: databaseClient)
    }
}
