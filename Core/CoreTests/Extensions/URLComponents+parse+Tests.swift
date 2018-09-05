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

class URLComponentsParseTests: XCTestCase {
    func testParseURL() {
        let string = "scheme://user:password@host/path/1/2/3?query=a&b#fragment"
        let url = URL(string: string)!
        XCTAssertEqual(URLComponents.parse(url), URLComponents(string: string)!)
    }

    func testParseString() {
        let string = "scheme://user:password@host/path/1/2/3?query=a&b#fragment"
        XCTAssertEqual(URLComponents.parse(string), URLComponents(string: string)!)
    }

    func testParseBadString() {
        let string = "scheme://host space/path|<>&:@%25?query=a&b#fragment"
        let url = URLComponents.parse(string)
        XCTAssertEqual(url.scheme, "scheme")
        XCTAssertEqual(url.host, "host space")
        XCTAssertEqual(url.path, "/path|<>&:@%")
        XCTAssertEqual(url.query, "query=a&b")
        XCTAssertEqual(url.fragment, "fragment")
    }

    func testParseReallyBadString() {
        let url = URLComponents.parse("%")
        XCTAssertEqual(url.scheme, nil)
        XCTAssertEqual(url.host, nil)
        XCTAssertEqual(url.path, "%")
        XCTAssertEqual(url.query, nil)
        XCTAssertEqual(url.fragment, nil)
        XCTAssertEqual(URLComponents.parse("").path, "")
    }
}
