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

class ContextTests: XCTestCase {
    func testTypePathComponent() {
        XCTAssertEqual(ContextType.account.pathComponent, "accounts")
        XCTAssertEqual(ContextType.course.pathComponent, "courses")
        XCTAssertEqual(ContextType.group.pathComponent, "groups")
        XCTAssertEqual(ContextType.user.pathComponent, "users")
        XCTAssertEqual(ContextType.section.pathComponent, "sections")
    }

    func testInitTypeWithPathComponent() {
        XCTAssertEqual(ContextType(pathComponent: "accounts"), .account)
        XCTAssertEqual(ContextType(pathComponent: "courses"), .course)
        XCTAssertEqual(ContextType(pathComponent: "groups"), .group)
        XCTAssertEqual(ContextType(pathComponent: "users"), .user)
        XCTAssertEqual(ContextType(pathComponent: "sections"), .section)
        XCTAssertNil(ContextType(pathComponent: "chums"))
    }

    func testCanvasContextID() {
        XCTAssertEqual(Context(.account, id: "1").canvasContextID, "account_1")
        XCTAssertEqual(Context(.course, id: "2").canvasContextID, "course_2")
        XCTAssertEqual(Context(.group, id: "3").canvasContextID, "group_3")
        XCTAssertEqual(Context(.user, id: "4").canvasContextID, "user_4")
        XCTAssertEqual(Context(.section, id: "5").canvasContextID, "section_5")
    }

    func testPathComponent() {
        XCTAssertEqual(Context(.account, id: "1").pathComponent, "accounts/1")
        XCTAssertEqual(Context(.course, id: "2").pathComponent, "courses/2")
        XCTAssertEqual(Context(.group, id: "3").pathComponent, "groups/3")
        XCTAssertEqual(Context(.user, id: "4").pathComponent, "users/4")
        XCTAssertEqual(Context(.section, id: "5").pathComponent, "sections/5")
    }
}
