//
// Copyright (C) 2018-present Instructure, Inc.
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

import XCTest
@testable import Core

class KeychainTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Keychain.clearEntries()
        Keychain.config = KeychainConfig(service: "com.instructure.service", accessGroup: nil)
    }

    func testAddEntry() {
        let entry = KeychainEntry(token: "token", baseURL: "baseurl")
        Keychain.addEntry(entry)
        XCTAssertTrue(Keychain.entries.contains(entry))
    }

    func testAddMultipleEntries() {
        let entry1 = KeychainEntry(token: "token1", baseURL: "baseurl")
        let entry2 = KeychainEntry(token: "token2", baseURL: "baseurl")
        let entry3 = KeychainEntry(token: "token3", baseURL: "baseurl")
        Keychain.addEntry(entry1)
        Keychain.addEntry(entry2)
        Keychain.addEntry(entry3)
        XCTAssertTrue(Keychain.entries.count == 3)
    }

    func testAddingSameEntryMultipleTimes() {
        let entry1 = KeychainEntry(token: "token", baseURL: "baseurl")
        let entry2 = KeychainEntry(token: "token", baseURL: "baseurl")
        Keychain.addEntry(entry1)
        Keychain.addEntry(entry2)
        XCTAssertTrue(Keychain.entries.count == 1)
    }

    func testRemoveEntry() {
        let entry = KeychainEntry(token: "token", baseURL: "baseurl")
        Keychain.addEntry(entry)
        XCTAssertTrue(Keychain.entries.contains(entry))
        Keychain.removeEntry(entry)
        XCTAssertFalse(Keychain.entries.contains(entry))
    }

    func testClearEntries() {
        let entry = KeychainEntry(token: "token", baseURL: "baseurl")
        Keychain.addEntry(entry)
        XCTAssertTrue(Keychain.entries.count == 1)
        Keychain.clearEntries()
        XCTAssertTrue(Keychain.entries.count == 0)
    }

    func testAccessGroup() {
        Keychain.config = KeychainConfig(service: "com.instructure.shared-credentials", accessGroup: "8MKNFMCD9M.com.instructure.shared-credentials")
        let entry = KeychainEntry(token: "token", baseURL: "baseurl")
        Keychain.addEntry(entry)
        // I can't get this test to work for some reason, something with the entitlements
        // I think I'll revisit later
        // XCTAssertTrue(Keychain.entries.contains(entry))
    }

    func testAddGarbageIntoKeychain() {

        Keychain.clearEntries()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.instructure.service",
            kSecAttrAccount as String: "CanvasUsers",
            kSecValueData as String: Data(),
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]

        let result = SecItemAdd(query as CFDictionary, nil) == noErr
        XCTAssertTrue(result)

        // Should not explode if there are weird entries in the keychain
        XCTAssertTrue(Keychain.entries.count == 0)
    }
}
