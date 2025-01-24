//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class CacheManagerTests: CoreTestCase {
    let rnManifestURL = URL.Directories.documents
        .appendingPathComponent("RCTAsyncLocalStorage_V1")
        .appendingPathComponent("manifest.json")

    var backupEntries: Set<LoginSession>!
    var backupManifest: Data?

    override func setUp() {
        super.setUp()
        backupManifest = try? Data(contentsOf: rnManifestURL)
    }

    override func tearDown() {
        super.tearDown()
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
        let doc = write("doc", in: URL.Directories.documents)
        let annotated = write("pdf content annotated", in: URL.Directories.annotatedPDFs)
        LoginSession.add(LoginSession.make())
        CacheManager.resetAppIfNecessary()
        XCTAssertNil(UserDefaults.standard.dictionaryRepresentation()["reset_cache_on_next_launch"])
        XCTAssertFalse(FileManager.default.fileExists(atPath: doc.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: annotated.path))
        XCTAssert(LoginSession.sessions.isEmpty)
    }

    func testClearNoNeeded() {
        UserDefaults.standard.set(CacheManager.bundleVersion, forKey: "lastDeletedAt")
        let cache = write("cache", in: URL.Directories.caches)
        CacheManager.clearIfNeeded()
        XCTAssertTrue(FileManager.default.fileExists(atPath: cache.path))
        try? FileManager.default.removeItem(at: cache)
    }

    func testClearNeeded() {
        UserDefaults.standard.set(-1, forKey: "lastDeletedAt")
        environment.userDefaults?.showGradesOnDashboard = true
        let cache = write("cache", in: URL.Directories.caches)
        let doc = write("doc", in: URL.Directories.documents)
        CacheManager.clearIfNeeded()
        XCTAssertFalse(FileManager.default.fileExists(atPath: cache.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: doc.path))
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "lastDeletedAt"), CacheManager.bundleVersion)
        try? FileManager.default.removeItem(at: doc)
        XCTAssertEqual(environment.userDefaults?.showGradesOnDashboard, true)
    }

    func testClearRNAsyncStorage() {
        let asyncStorage = URL.Directories.documents.appendingPathComponent("RCTAsyncLocalStorage_V1")
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
