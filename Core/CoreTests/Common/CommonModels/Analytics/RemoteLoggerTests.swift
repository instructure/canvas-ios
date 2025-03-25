//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import TestsFoundation

class RemoteLoggerTests: XCTestCase {
    private var mockLogHandler: MockRemoteLogHandler!
    private var testee: RemoteLogger!

    override func setUp() {
        super.setUp()
        mockLogHandler = MockRemoteLogHandler()
        testee = RemoteLogger()
        testee.handler = mockLogHandler
    }

    func testBreadcrumb() {
        testee.logBreadcrumb(
            route: "/testRoute",
            viewController: ProfileSettingsViewController()
        )

        XCTAssertEqual(
            mockLogHandler.breadCrumbs,
            ["Routing to: /testRoute (ProfileSettingsViewController)"]
        )
    }

    func testLogError() {
        testee.logError(name: "test_error", reason: "this is a test error")
        XCTAssertEqual(mockLogHandler.lastErrorName, "test_error")
        XCTAssertEqual(mockLogHandler.lastErrorReason, "this is a test error")
    }
}
