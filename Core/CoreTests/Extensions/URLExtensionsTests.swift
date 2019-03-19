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

class URLExtensionsTests: XCTestCase {

    let path = URL(fileURLWithPath: "\(NSTemporaryDirectory())submissions/")

    func setup() {
        deleteTempDir()
    }

    func deleteTempDir() {
        XCTAssertNoThrow( try FileManager.default.removeItem(at: path) )
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
}
