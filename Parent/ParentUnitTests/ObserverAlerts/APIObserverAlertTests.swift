//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Parent
import TestsFoundation

class APIObserverAlertTests: ParentTestCase {
    func testGetObserverAlertsRequest() {
        let req = GetObserverAlertsRequest(studentID: "2")
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "users/self/observer_alerts/2")
        XCTAssertEqual(req.query, [ .perPage(100) ])
    }

    func testMarkObserverAlertReadRequest() {
        let req = PutObserverAlertReadRequest(alertID: "7")
        XCTAssertEqual(req.method, .put)
        XCTAssertEqual(req.path, "users/self/observer_alerts/7/read")
    }

    func testDismissObserverAlertRequest() {
        let req = PutObserverAlertDismissedRequest(alertID: "4")
        XCTAssertEqual(req.method, .put)
        XCTAssertEqual(req.path, "users/self/observer_alerts/4/dismissed")
    }
}
