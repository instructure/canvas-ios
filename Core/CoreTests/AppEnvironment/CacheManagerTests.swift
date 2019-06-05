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
@testable import Core

class CacheManagerTests: CoreTestCase {
    let rnManifestURL = URL.documentsDirectory
        .appendingPathComponent("RCTAsyncLocalStorage_V1")
        .appendingPathComponent("manifest.json")

    var backupEntries: Set<KeychainEntry>!
    var backupManifest: Data?

    override func setUp() {
        super.setUp()
        backupEntries = Keychain.entries
        backupManifest = try? Data(contentsOf: rnManifestURL)
    }

    override func tearDown() {
        super.tearDown()
        Keychain.clearEntries()
        for entry in backupEntries {
            Keychain.addEntry(entry)
        }
        try? backupManifest?.write(to: rnManifestURL, options: .atomic)
    }

    func write(_ string: String, in dir: URL) -> URL {
        let url = dir.appendingPathComponent("string.txt")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try! string.data(using: .utf8)!.write(to: url)
        return url
    }

    func testBundleVersion() {
        XCTAssertNotEqual(CacheManager.bundleVersion, 0)
    }

    func testResetAppNotNecessary() {
        UserDefaults.standard.setValue(false, forKey: "reset_cache_on_next_launch")
        CacheManager.resetAppIfNecessary()
        XCTAssertEqual(UserDefaults.standard.dictionaryRepresentation()["reset_cache_on_next_launch"] as? Bool, false)
    }

    func testResetAppNecessary() {
        UserDefaults.standard.setValue(true, forKey: "reset_cache_on_next_launch")
        let doc = write("doc", in: .documentsDirectory)
        Keychain.addEntry(KeychainEntry.make())
        CacheManager.resetAppIfNecessary()
        XCTAssertNil(UserDefaults.standard.dictionaryRepresentation()["reset_cache_on_next_launch"])
        XCTAssertFalse(FileManager.default.fileExists(atPath: doc.path))
        XCTAssert(Keychain.entries.isEmpty)
    }

    func testClearNoNeeded() {
        UserDefaults.standard.set(CacheManager.bundleVersion, forKey: "lastDeletedAt")
        let cache = write("cache", in: .cachesDirectory)
        CacheManager.clearIfNeeded()
        XCTAssertTrue(FileManager.default.fileExists(atPath: cache.path))
        try? FileManager.default.removeItem(at: cache)
    }

    func testClearNeeded() {
        UserDefaults.standard.set(-1, forKey: "lastDeletedAt")
        let cache = write("cache", in: .cachesDirectory)
        let doc = write("doc", in: .documentsDirectory)
        CacheManager.clearIfNeeded()
        XCTAssertFalse(FileManager.default.fileExists(atPath: cache.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: doc.path))
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "lastDeletedAt"), CacheManager.bundleVersion)
        try? FileManager.default.removeItem(at: doc)
    }

    func testClearRNAsyncStorage() {
        let asyncStorage = URL.documentsDirectory.appendingPathComponent("RCTAsyncLocalStorage_V1")
        try? FileManager.default.createDirectory(at: asyncStorage, withIntermediateDirectories: true)
        try! """
            { "speed-grader-tutorial": "preserved", "something-else": "removed" }
        """.data(using: .utf8)?.write(to: rnManifestURL)
        let extra = write("extra", in: asyncStorage)
        CacheManager.clearRNAsyncStorage()
        let json = (try? Data(contentsOf: rnManifestURL)).flatMap { try? JSONSerialization.jsonObject(with: $0) } as? [String: Any]
        XCTAssertFalse(FileManager.default.fileExists(atPath: extra.path))
        XCTAssertEqual(json?["speed-grader-tutorial"] as? String, "preserved")
        XCTAssertNil(json?["something-else"])
    }
}
