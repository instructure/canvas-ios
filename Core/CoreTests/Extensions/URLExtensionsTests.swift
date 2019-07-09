//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class URLExtensionsTests: XCTestCase {

    let path = URL(fileURLWithPath: "\(NSTemporaryDirectory())submissions/")
    let fs = FileManager.default

    func setup() {
        deleteTempDir()
    }

    func deleteTempDir() {
        XCTAssertNoThrow( try fs.removeItem(at: path) )
    }

    func testLookupFileSize() {
        let url = Bundle(for: URLExtensionsTests.self).url(forResource: "Info", withExtension: "plist")
        XCTAssertGreaterThan(url!.lookupFileSize(), 500)
        XCTAssertEqual(URL(string: "bogus")?.lookupFileSize(), 0)
        XCTAssertEqual(URL(fileURLWithPath: "bogus").lookupFileSize(), 0)
    }

    func testAppendingQueryItems() {
        let url = URL(string: "/")?.appendingQueryItems(URLQueryItem(name: "a", value: "b"), URLQueryItem(name: "c", value: nil))
        XCTAssertEqual(url?.absoluteString, "/?a=b&c")
    }

    func testTemporaryDirectory() {
        XCTAssertEqual(URL.temporaryDirectory, URL(fileURLWithPath: NSTemporaryDirectory()))
    }

    func testCachesDirectory() {
        XCTAssertEqual(URL.cachesDirectory, fs.urls(for: .cachesDirectory, in: .userDomainMask)[0])
    }

    func testDocumentsDirectory() {
        XCTAssertEqual(URL.documentsDirectory, fs.urls(for: .documentDirectory, in: .userDomainMask)[0])
    }
}
