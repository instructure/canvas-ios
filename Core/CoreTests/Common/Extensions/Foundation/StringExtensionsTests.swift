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

class StringExtensionsTests: XCTestCase {

    func testPopulatePathWithNilParams() {
        let path = "https://localhost/foo"
        let result = path.populatePathWithParams(nil)
        XCTAssertNil(result)
    }

    func testPopulatePathWithParams() {
        let path = "https://localhost/courses/:courseID/assignments/:assignmentID"
        let result = path.populatePathWithParams(["courseID": "1", "assignmentID": "1"])
        XCTAssertEqual(result, "/courses/1/assignments/1")
    }

    func testPruneApiVersionFromPath() {
        let path = "/api/v1/courses/1/assignments/1"
        let result = path.pruneApiVersionFromPath()
        XCTAssertEqual(result, "/courses/1/assignments/1")
    }

    func testRemovingXMLEscaping() {
        XCTAssertEqual("&lt;&gt;&amp;&apos;&quot;".removingXMLEscaping, "<>&'\"")
        XCTAssertEqual("ltilaunch?custom_productId=1&amp;custom_resourceid=2&amp;type=3".removingXMLEscaping, "ltilaunch?custom_productId=1&custom_resourceid=2&type=3")
        XCTAssertEqual("<>&'\"".removingXMLEscaping, "<>&'\"")
        XCTAssertEqual("&amp=&gt;".removingXMLEscaping, "&amp=>")
    }

    func testContainsNumbers() {
        XCTAssertFalse("".containsNumber)
        XCTAssertFalse("test".containsNumber)
        XCTAssertTrue("123".containsNumber)
        XCTAssertTrue("test123".containsNumber)
    }

    func testContainsOnlyNumbers() {
        XCTAssertFalse("test".containsOnlyNumbers)
        XCTAssertFalse("test123".containsOnlyNumbers)
        XCTAssertFalse("-123".containsOnlyNumbers)
        XCTAssertTrue("".containsOnlyNumbers)
        XCTAssertTrue("123".containsOnlyNumbers)
    }

    func testIsNotEmpty() {
        XCTAssertFalse("".isNotEmpty)
        XCTAssertTrue("test".isNotEmpty)
    }

    func testNilIfEmpty() {
        XCTAssertEqual("".nilIfEmpty, nil)
        XCTAssertEqual("test".nilIfEmpty, "test")
    }

    func testNSRange() {
        XCTAssertEqual("test".nsRange, NSRange(location: 0, length: 4))
    }

    func testExtractsIFrames() {
        let testHTML = "<iframe param=1>content</iframe><iframe></iframe>"

        let results = testHTML.extractiFrames()

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first, "<iframe param=1>content</iframe>")
        XCTAssertEqual(results.last, "<iframe></iframe>")
    }

    func testDeletesPrefix() {
        XCTAssertEqual("Canvas1".deletingPrefix("Canvas"), "1")
        XCTAssertEqual("1Canvas1".deletingPrefix("Canvas"), "1Canvas1")
    }

    func testSHA256() {
        let text1 = "Some text 1"
        let text2 = "Some text 2"

        let hash1 = text1.sha256()
        let hash2 = text2.sha256()
        XCTAssertEqual(hash1 != hash2, true)
        XCTAssertEqual(hash1, text1.sha256())
    }

    func testJoinedForOptionalStrings() {
        var texts: [String?] = ["one", nil, "three"]
        XCTAssertEqual(texts.joined(separator: ","), "one,three")
        XCTAssertEqual(texts.joined(separator: ""), "onethree")

        texts = ["1", "", "3"]
        XCTAssertEqual(texts.joined(separator: ","), "1,,3")

        texts = ["3"]
        XCTAssertEqual(texts.joined(separator: ","), "3")

        texts = []
        XCTAssertEqual(texts.joined(separator: "."), "")
    }

    func testIsNilOrEmpty() {
        XCTAssertEqual((nil as String?).isNilOrEmpty, true)
        XCTAssertEqual(("" as String?).isNilOrEmpty, true)
        XCTAssertEqual(("a" as String?).isNilOrEmpty, false)
    }
}
