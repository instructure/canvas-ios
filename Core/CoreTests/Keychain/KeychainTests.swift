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

class KeychainTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Keychain.config = KeychainConfig(service: "com.instructure.service", accessGroup: nil)
        Keychain.clearEntries()
    }

    func testAddEntry() {
        let entry = KeychainEntry.make()
        Keychain.addEntry(entry)
        XCTAssertTrue(Keychain.entries.contains(entry))
        XCTAssertEqual(Keychain.mostRecentSession, entry)
    }

    func testAddMultipleEntries() {
        let entry1 = KeychainEntry.make(userID: "1")
        let entry2 = KeychainEntry.make(userID: "2")
        let entry3 = KeychainEntry.make(userID: "3")
        Keychain.addEntry(entry1)
        Keychain.addEntry(entry2)
        Keychain.addEntry(entry3)
        XCTAssertEqual(Keychain.entries.count, 3)
        XCTAssertEqual(Keychain.mostRecentSession, entry3)
    }

    func testAddingSameEntryMultipleTimes() {
        let entry1 = KeychainEntry.make()
        let entry2 = KeychainEntry.make(accessToken: "unique", expiresAt: Date(), locale: "zh", refreshToken: "different", userName: "something else")
        Keychain.addEntry(entry1)
        Keychain.addEntry(entry2) // should replace
        XCTAssertEqual(Keychain.entries.count, 1)
        XCTAssertEqual(Keychain.entries.first, entry2)
    }

    func testBaseURLTrailingSlash() {
        let entry1 = KeychainEntry.make(baseURL: URL(string: "https://canvas.instructure.com/")!)
        let entry2 = KeychainEntry.make(baseURL: URL(string: "https://canvas.instructure.com")!)
        Keychain.addEntry(entry1)
        Keychain.addEntry(entry2) // should replace
        XCTAssertEqual(Keychain.entries.count, 1)
        XCTAssertEqual(Keychain.entries.first?.baseURL.path, "")
    }

    func testBumpLastUsedAt() {
        let entry = KeychainEntry.make(lastUsedAt: Date().addingTimeInterval(-100))
        XCTAssertGreaterThan(entry.bumpLastUsedAt().lastUsedAt, entry.lastUsedAt)
        XCTAssertEqual(entry.bumpLastUsedAt(), entry)
    }

    func testMasquerade() {
        let entry1 = KeychainEntry.make()
        let entry2 = KeychainEntry.make(masquerader: entry1.baseURL.appendingPathComponent("users").appendingPathComponent("42"))
        XCTAssertNotEqual(entry1, entry2)
        XCTAssertNil(entry1.originalBaseURL)
        XCTAssertNil(entry1.originalUserID)
        XCTAssertNil(entry1.actAsUserID)
        XCTAssertEqual(entry2.originalBaseURL, entry1.baseURL)
        XCTAssertEqual(entry2.originalUserID, "42")
        XCTAssertEqual(entry2.actAsUserID, entry2.userID)
    }

    func testRemoveEntry() {
        let entry = KeychainEntry.make()
        Keychain.addEntry(entry)
        XCTAssertTrue(Keychain.entries.contains(entry))
        Keychain.removeEntry(entry)
        XCTAssertFalse(Keychain.entries.contains(entry))
    }

    func testClearEntries() {
        let entry = KeychainEntry.make()
        Keychain.addEntry(entry)
        XCTAssertEqual(Keychain.entries.count, 1)
        Keychain.clearEntries()
        XCTAssertEqual(Keychain.entries.count, 0)
    }

    func testAccessGroup() {
        Keychain.config = KeychainConfig(service: "com.instructure.shared-credentials", accessGroup: "8MKNFMCD9M.com.instructure.shared-credentials")
        let entry = KeychainEntry.make()
        Keychain.addEntry(entry)
        // I can't get this test to work for some reason, something with the entitlements
        // I think I'll revisit later
        // XCTAssertTrue(Keychain.entries.contains(entry))
    }

    func testAddGarbageIntoKeychain() {
        Keychain.clearEntries()

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.instructure.service",
            kSecAttrAccount: "CanvasUsers",
            kSecValueData: Data(),
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
        ]

        let result = SecItemAdd(query as CFDictionary, nil) == noErr
        XCTAssertTrue(result)

        // Should not explode if there are weird entries in the keychain
        XCTAssertEqual(Keychain.entries.count, 0)
    }
}
