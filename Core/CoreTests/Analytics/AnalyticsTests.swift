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

    var loggedEvent: String?
    var loggedParameters: [String: Any]?

    override func setUp() {
        super.setUp()
        Analytics.shared.handler = self
    }

    func testLogEvent() {
        let name = "foobar"
        let params = ["bar": "foo"]
        Analytics.shared.logEvent(name, parameters: params)

        XCTAssertEqual(loggedEvent, name)
        XCTAssertEqual(loggedParameters?["bar"] as? String, "foo")
    }

    func testLogSession() {
        var session = LoginSession.make(expiresAt: nil)
        var defaults = SessionDefaults(sessionID: session.uniqueID)
        defaults.reset()

        Analytics.shared.logSession(session)
        XCTAssertEqual(loggedEvent, "auth_forever_token")

        loggedEvent = nil
        Analytics.shared.logSession(session)
        XCTAssertNil(loggedEvent)

        session = LoginSession.make(expiresAt: Date())
        Analytics.shared.logSession(session)
        XCTAssertEqual(loggedEvent, "auth_expiring_token")

        defaults.reset()
    }
}

extension AnalyticsTests: AnalyticsHandler {
    func handleEvent(_ name: String, parameters: [String: Any]?) {
        loggedEvent = name
        loggedParameters = parameters
    }
}
