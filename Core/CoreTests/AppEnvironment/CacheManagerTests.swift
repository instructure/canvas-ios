//
// Copyright (C) 2019-present Instructure, Inc.
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
