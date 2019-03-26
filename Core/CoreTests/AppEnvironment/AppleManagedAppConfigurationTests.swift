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
    override func setUp() {
        super.setUp()
        MDMManager.reset()
    }

    func testOnLoginConfigured() {
        var login: MDMLogin?
        let expectation = XCTestExpectation(description: "on login configured")
        MDMManager.shared.onLoginConfigured {
            login = $0
            expectation.fulfill()
        }
        MDMManager.mockDefaults()
        NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: nil)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(login?.host, "pcraighill.instructure.com")
        XCTAssertEqual(login?.username, "apple")
        XCTAssertEqual(login?.password, "titaniumium")
        XCTAssertNotNil(MDMManager.shared.login)
    }

    func testOnDemoEnabledOnlyCalledOnce() {
        let one = XCTestExpectation(description: "first callback")
        one.expectedFulfillmentCount = 1 // default, but being explicit here
        MDMManager.shared.onLoginConfigured { _ in
            one.fulfill() // automatically fails if called more than once
        }
        MDMManager.mockDefaults()
        wait(for: [one], timeout: 0.1)
        let two = XCTestExpectation(description: "second callback")
        MDMManager.shared.onLoginConfigured { _ in
            two.fulfill()
        }
        wait(for: [two], timeout: 0.1)
    }

    func testDeinit() {
        var config: MDMManager? = MDMManager()
        let expectation = XCTestExpectation(description: "callback should not be called")
        expectation.isInverted = true
        config?.onLoginConfigured { _ in
            expectation.fulfill()
        }
        config = nil
        MDMManager.mockDefaults()
        wait(for: [expectation], timeout: 0.1)
    }
}
