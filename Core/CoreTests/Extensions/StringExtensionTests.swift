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

class StringExtensionTests: XCTestCase {

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
}
