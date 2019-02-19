//
// Copyright (C) 2016-present Instructure, Inc.
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
import TestsFoundation

class RefreshKeychainEntryTests: CoreTestCase {
    override func setUp() {
        super.setUp()
        Keychain.config = KeychainConfig(service: "com.instructure.service", accessGroup: nil)
        Keychain.clearEntries()
    }

    func testSave() {
        let entry = KeychainEntry.make(userAvatarURL: nil, userName: "Eve")
        Keychain.addEntry(entry)
        Keychain.currentSession = entry
        let responseData = try? JSONEncoder().encode(APIUser.make([ "avatar_url": "avatar", "name": "Evelyn" ]))
        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))
        let useCase = RefreshKeychainEntry(entry, session: .mockSession())
        addOperationAndWait(useCase)
        XCTAssertNoThrow(useCase.save(nil))
        XCTAssertEqual(Keychain.entries.first?.userName, "Evelyn")
        XCTAssertEqual(Keychain.currentSession?.userAvatarURL, URL(string: "avatar"))
    }
}
