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
        XCTAssertEqual(Context.currentUser, Context(.user, id: "self"))
    }

    func testInitContextTypeId() {
        let context = Context(.course, id: "5")
        XCTAssertEqual(context.contextType, .course)
        XCTAssertEqual(context.id, "5")
    }

    func testInitContextID() {
        XCTAssertEqual(Context(canvasContextID: "group_42"), Context(.group, id: "42"))

        XCTAssertNil(Context(canvasContextID: "invalid"))
        XCTAssertNil(Context(canvasContextID: "invalid_1"))
    }

    func testInitPath() {
        XCTAssertEqual(Context(path: "groups/42"), Context(.group, id: "42"))
        XCTAssertEqual(Context(path: "/api/v1/users/4"), Context(.user, id: "4"))

        XCTAssertNil(Context(path: "invalid"))
        XCTAssertNil(Context(path: "invalid/1"))
        XCTAssertNil(Context(path: "/api/v1/invalid/1"))
    }

    func testInitUrl() {
        XCTAssertEqual(Context(url: URL(string: "api/v1/accounts/self")!), Context(.account, id: "self"))
        XCTAssertNil(Context(url: URL(string: "/api/v1/")!))
    }
}
