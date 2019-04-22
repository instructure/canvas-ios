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
    let manager = CacheManager()

    func write(_ string: String, in dir: URL) -> URL {
        let url = dir.appendingPathComponent("string.txt")
        try! string.data(using: .utf8)!.write(to: url)
        return url
    }

    func testDeleteCaches() {
        let url = write("hello", in: .cachesDirectory)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertNoThrow(try manager.deleteCaches())
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    }

    func testDeleteDocuments() {
        let url = write("hello", in: .documentsDirectory)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertNoThrow(try manager.deleteDocuments())
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    }

    func testDeleteAll() {
        let now = Date()
        Clock.mockNow(now)
        let cache = write("cache", in: .cachesDirectory)
        let document = write("doc", in: .documentsDirectory)
        XCTAssertTrue(FileManager.default.fileExists(atPath: cache.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: document.path))
        XCTAssertNoThrow(try manager.deleteAll())
        XCTAssertFalse(FileManager.default.fileExists(atPath: cache.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: document.path))
        XCTAssertEqual(manager.lastDeletedAt, now)
    }
}
