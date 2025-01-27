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
import TestsFoundation

class AnalyticsTests: XCTestCase {
    private var testAnalyticsHandler: MockAnalyticsHandler!

    override func setUp() {
        super.setUp()
        testAnalyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = testAnalyticsHandler
    }

    func testLogEvent() {
        let name = "foobar"
        let params = ["bar": "foo"]
        Analytics.shared.logEvent(name, parameters: params)

        XCTAssertEqual(testAnalyticsHandler.lastEvent, name)
        XCTAssertEqual(testAnalyticsHandler.lastEventParameters?["bar"] as? String, "foo")
    }

    func testLogSession() {
        var session = LoginSession.make(expiresAt: nil)
        var defaults = SessionDefaults(sessionID: session.uniqueID)
        defaults.reset()

        Analytics.shared.logSession(session)
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "auth_forever_token")

        testAnalyticsHandler.lastEvent = nil
        Analytics.shared.logSession(session)
        XCTAssertNil(testAnalyticsHandler.lastEvent)

        session = LoginSession.make(expiresAt: Date())
        Analytics.shared.logSession(session)
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "auth_expiring_token")

        defaults.reset()
    }

    func testAnalyticsBaseUrl() {
        AppEnvironment.shared.currentSession = nil
        XCTAssertEqual(Analytics.analyticsBaseUrl, "")

        AppEnvironment.shared.currentSession = .make(baseURL: URL(string: "https://canvas.instructure.com")!)
        XCTAssertEqual(Analytics.analyticsBaseUrl, "https://canvas.instructure.com")
    }
}
