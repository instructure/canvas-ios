//
// Copyright (C) 2018-present Instructure, Inc.
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

import XCTest
@testable import Core

class AppEnvironmentTests: CoreTestCase {
    func testUserDidLogin() {
        let env = AppEnvironment()
        env.userDidLogin(session: KeychainEntry.make(accessToken: "token"))
        XCTAssertEqual(env.api.accessToken, "token")
        XCTAssertEqual(env.backgroundAPI.accessToken, "token")
    }

    func testUserDidLogout() {
        let env = AppEnvironment()
        let current = KeychainEntry.make(accessToken: "token")
        env.userDidLogin(session: current)
        env.userDidLogout(session: KeychainEntry.make(userID: "7"))
        XCTAssertEqual(env.api.accessToken, "token")
        env.userDidLogout(session: current)
        XCTAssertNil(env.api.accessToken)
        XCTAssertNil(env.currentSession)
    }
}
