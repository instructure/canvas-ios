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

import XCTest
import Core
import CanvasKeymaster
@testable import Teacher
import TestsFoundation

class CKIClientExtensionsTests: TeacherTestCase {
    func testKeychainEntry() {
        let baseURL = URL(string: "https://canvas.instructure.com")!
        let client = CKIClient(baseURL: baseURL, token: "token")
        let user = CKIUser(id: "1")
        user?.name = "user"
        client?.setValue(user, forKey: #keyPath(CKIClient.currentUser))
        client?.originalIDOfMasqueradingUser = "2"
        XCTAssertEqual(client?.keychainEntry, KeychainEntry(
            accessToken: "token",
            baseURL: baseURL,
            expiresAt: nil,
            locale: client?.effectiveLocale,
            masquerader: baseURL.appendingPathComponent("users").appendingPathComponent("2"),
            refreshToken: nil,
            userAvatarURL: nil,
            userID: "1",
            userName: "user"
        ))
        XCTAssertNil(CKIClient().keychainEntry)
    }
}
