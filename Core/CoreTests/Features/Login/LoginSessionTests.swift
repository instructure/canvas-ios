//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class LoginSessionTests: CoreTestCase {
    func testAddEntry() {
        let entry = LoginSession.make()
        LoginSession.add(entry)
        XCTAssertTrue(LoginSession.sessions.contains(entry))
        XCTAssertEqual(LoginSession.mostRecent, entry)
    }

    func testAddMultipleEntries() {
        let entry1 = LoginSession.make(userID: "1")
        let entry2 = LoginSession.make(userID: "2")
        let entry3 = LoginSession.make(userID: "3")
        LoginSession.add(entry1)
        LoginSession.add(entry2)
        LoginSession.add(entry3)
        XCTAssertEqual(LoginSession.sessions.count, 3)
        XCTAssertEqual(LoginSession.mostRecent, entry3)
    }

    func testAddingSameEntryMultipleTimes() {
        let entry1 = LoginSession.make()
        let entry2 = LoginSession.make(accessToken: "unique", expiresAt: Date(), locale: "zh", refreshToken: "different", userName: "something else")
        LoginSession.add(entry1)
        LoginSession.add(entry2) // should replace
        XCTAssertEqual(LoginSession.sessions.count, 1)
        XCTAssertEqual(LoginSession.sessions.first, entry2)
    }

    func testBaseURLTrailingSlash() {
        let entry1 = LoginSession.make(baseURL: URL(string: "https://canvas.instructure.com/")!)
        let entry2 = LoginSession.make(baseURL: URL(string: "https://canvas.instructure.com")!)
        LoginSession.add(entry1)
        LoginSession.add(entry2) // should replace
        XCTAssertEqual(LoginSession.sessions.count, 1)
        XCTAssertEqual(LoginSession.sessions.first?.baseURL.path, "")
    }

    func testBumpLastUsedAt() {
        let entry = LoginSession.make(lastUsedAt: Date().addingTimeInterval(-100))
        XCTAssertGreaterThan(entry.bumpLastUsedAt().lastUsedAt, entry.lastUsedAt)
        XCTAssertEqual(entry.bumpLastUsedAt(), entry)
    }

    func testMasquerade() {
        let entry1 = LoginSession.make()
        let entry2 = LoginSession.make(masquerader: entry1.baseURL.appendingPathComponent("users").appendingPathComponent("42"))
        XCTAssertNotEqual(entry1, entry2)
        XCTAssertNil(entry1.originalBaseURL)
        XCTAssertNil(entry1.originalUserID)
        XCTAssertNil(entry1.actAsUserID)
        XCTAssertEqual(entry2.originalBaseURL, entry1.baseURL)
        XCTAssertEqual(entry2.originalUserID, "42")
        XCTAssertEqual(entry2.actAsUserID, entry2.userID)
    }

    func testRemoveEntry() {
        let entry = LoginSession.make()
        LoginSession.add(entry)
        XCTAssertTrue(LoginSession.sessions.contains(entry))
        LoginSession.remove(entry)
        XCTAssertFalse(LoginSession.sessions.contains(entry))
    }

    func testClearEntries() {
        let entry = LoginSession.make()
        LoginSession.add(entry)
        XCTAssertEqual(LoginSession.sessions.count, 1)
        LoginSession.clearAll()
        XCTAssertEqual(LoginSession.sessions.count, 0)
    }
}
