//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class PageViewSessionTests: XCTestCase {

    func testNewSession() {
        UserDefaults.standard.removeObject(forKey: PageViewSession.sessionCreationDateKey)
        UserDefaults.standard.removeObject(forKey: PageViewSession.UUIDKey)
        UserDefaults.standard.synchronize()

        _ = PageViewSession(defaultSessionLength: 5)
        let uid = UserDefaults.standard.string(forKey: PageViewSession.UUIDKey)
        let s = PageViewSession(defaultSessionLength: 1)
        XCTAssertEqual(uid, s.ID)
    }

    func testExpiredSession() {
        let now = Date()
        let expire = now.inCalendar.addMinutes(-2)
        let uuid = Foundation.UUID().uuidString
        UserDefaults.standard.setValue(expire, forKey: PageViewSession.sessionCreationDateKey)
        UserDefaults.standard.setValue(uuid, forKey: PageViewSession.UUIDKey)
        UserDefaults.standard.synchronize()

        let s = PageViewSession(defaultSessionLength: 1)
        XCTAssertNotEqual(uuid, s.ID)
    }
}
