//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
