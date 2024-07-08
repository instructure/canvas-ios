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

import Foundation
@testable import Core
import XCTest

class MDMManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        _ = MDMManager.shared // init lazy static
        MDMManager.reset()
    }

    func testUpdate() {
        MDMManager.mockDefaults()
        XCTAssertEqual(MDMManager.shared.logins, [
            MDMLogin(
                host: "canvas.instructure.com",
                username: "apple",
                password: "titaniumium"
            )
        ])
        MDMManager.mockNoUsers()
        XCTAssertEqual(MDMManager.shared.logins, [])
        MDMManager.mockBadUsers()
        XCTAssertEqual(MDMManager.shared.logins, [])
        MDMManager.mockHost()
        XCTAssertEqual(MDMManager.shared.host, "canvas.instructure.com")
        XCTAssertEqual(MDMManager.shared.authenticationProvider, "canvas")
    }

    func testDeinit() {
        MDMManager.mockDefaults()
        var config: MDMManager? = MDMManager()
        XCTAssertNotNil(config?.loginsRaw)
        config = nil
        MDMManager.reset()
        // Not sure how to check NotificationCenter.default.removeObserver was called.
    }
}
