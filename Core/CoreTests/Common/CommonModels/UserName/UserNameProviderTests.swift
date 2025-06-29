//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class UserNameProviderTests: XCTestCase {

    func test_displayName() {
        XCTAssertEqual(User.displayName("Jane Doe", pronouns: nil), "Jane Doe")
        XCTAssertEqual(User.displayName("Jane Doe", pronouns: "She/Her"), "Jane Doe (She/Her)")
    }

    func test_initials() {
        XCTAssertEqual(User.initials(for: "Jane Doe"), "JD")
        XCTAssertEqual(User.initials(for: "jane doe"), "JD")
        XCTAssertEqual(User.initials(for: "Group 2"), "G2")

        XCTAssertEqual(User.initials(for: "janedoe"), "J")
        XCTAssertEqual(User.initials(for: "jane doe the third"), "JD")
        XCTAssertEqual(User.initials(for: ""), "")
    }

    func test_scrubbedAvatarUrls() {
        XCTAssertNotEqual(User.scrubbedAvatarUrl(URL(string: "some/url")!), nil)

        XCTAssertEqual(User.scrubbedAvatarUrl(URL(string: "images/dotted_pic.png")!), nil)
        XCTAssertEqual(User.scrubbedAvatarUrl(URL(string: "some/url/andimages/dotted_pic.png")!), nil)
        XCTAssertEqual(User.scrubbedAvatarUrl(URL(string: "images/messages/avatar-50.png")!), nil)
        XCTAssertEqual(User.scrubbedAvatarUrl(URL(string: "some/url/andimages/messages/avatar-50.png")!), nil)
    }
}
