//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
@testable import Core

class Context_Tests: XCTestCase {
    func testTypePathComponent() {
        XCTAssertEqual(ContextType.account.pathComponent, "accounts")
        XCTAssertEqual(ContextType.course.pathComponent, "courses")
        XCTAssertEqual(ContextType.group.pathComponent, "groups")
        XCTAssertEqual(ContextType.user.pathComponent, "users")
    }

    func testCanvasContextID() {
        XCTAssertEqual(ContextModel(.account, id: "1").canvasContextID, "account_1")
        XCTAssertEqual(ContextModel(.course, id: "2").canvasContextID, "course_2")
        XCTAssertEqual(ContextModel(.group, id: "3").canvasContextID, "group_3")
        XCTAssertEqual(ContextModel(.user, id: "4").canvasContextID, "user_4")
    }

    func testPathComponent() {
        XCTAssertEqual(ContextModel(.account, id: "1").pathComponent, "accounts/1")
        XCTAssertEqual(ContextModel(.course, id: "2").pathComponent, "courses/2")
        XCTAssertEqual(ContextModel(.group, id: "3").pathComponent, "groups/3")
        XCTAssertEqual(ContextModel(.user, id: "4").pathComponent, "users/4")
    }
}
