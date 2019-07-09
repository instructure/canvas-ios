//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
@testable import Core

class ContextModelTests: XCTestCase {
    func testCurrentUser() {
        XCTAssertEqual(ContextModel.currentUser, ContextModel(.user, id: "self"))
    }

    func testInitContextTypeId() {
        let context = ContextModel(.course, id: "5")
        XCTAssertEqual(context.contextType, .course)
        XCTAssertEqual(context.id, "5")
    }

    func testInitContextID() {
        XCTAssertEqual(ContextModel(canvasContextID: "group_42"), ContextModel(.group, id: "42"))

        XCTAssertNil(ContextModel(canvasContextID: "invalid"))
        XCTAssertNil(ContextModel(canvasContextID: "invalid_1"))
    }

    func testInitPath() {
        XCTAssertEqual(ContextModel(path: "groups/42"), ContextModel(.group, id: "42"))
        XCTAssertEqual(ContextModel(path: "/api/v1/users/4"), ContextModel(.user, id: "4"))

        XCTAssertNil(ContextModel(path: "invalid"))
        XCTAssertNil(ContextModel(path: "invalid/1"))
        XCTAssertNil(ContextModel(path: "/api/v1/invalid/1"))
    }

    func testInitUrl() {
        XCTAssertEqual(ContextModel(url: URL(string: "api/v1/accounts/self")!), ContextModel(.account, id: "self"))
        XCTAssertNil(ContextModel(url: URL(string: "/api/v1/")!))
    }
}
