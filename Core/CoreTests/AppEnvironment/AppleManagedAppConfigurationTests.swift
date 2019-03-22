//
// Copyright (C) 2019-present Instructure, Inc.
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

import Foundation
@testable import Core
import XCTest

class AppleManagedAppConfigurationTests: XCTestCase {
    func testOnDemoEnabled() {
        var demo: AppleManagedAppConfiguration.Demo?
        let expectation = XCTestExpectation(description: "on demo enabled")
        AppleManagedAppConfiguration.shared.onDemoEnabled {
            demo = $0
            expectation.fulfill()
        }
        AppleManagedAppConfiguration.mockDefaults()
        NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: nil)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(demo?.host, "pcraighill.instructure.com")
        XCTAssertEqual(demo?.username, "apple")
        XCTAssertEqual(demo?.password, "titaniumium")
        XCTAssertNotNil(AppleManagedAppConfiguration.shared.demo)
    }

    func testOnDemoEnabledOnlyCalledOnce() {
        let one = XCTestExpectation(description: "first callback")
        one.expectedFulfillmentCount = 1 // default, but being explicit here
        AppleManagedAppConfiguration.shared.onDemoEnabled { _ in
            one.fulfill() // automatically fails if called more than once
        }
        AppleManagedAppConfiguration.mockDefaults()
        wait(for: [one], timeout: 0.1)
        let two = XCTestExpectation(description: "second callback")
        AppleManagedAppConfiguration.shared.onDemoEnabled { _ in
            two.fulfill()
        }
        wait(for: [two], timeout: 0.1)
    }

    func testDeinit() {
        var config: AppleManagedAppConfiguration? = AppleManagedAppConfiguration()
        let expectation = XCTestExpectation(description: "callback should not be called")
        expectation.isInverted = true
        config?.onDemoEnabled { _ in
            expectation.fulfill()
        }
        config = nil
        AppleManagedAppConfiguration.mockDefaults()
        wait(for: [expectation], timeout: 0.1)
    }
}
