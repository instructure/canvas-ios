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

class URLComponentsExtensionsTests: XCTestCase {
    func testParseURL() {
        let string = "scheme://user:password@host/path/1/2/3?query=a&b#fragment"
        let url = URL(string: string)!
        XCTAssertEqual(URLComponents.parse(url), URLComponents(string: string)!)
    }

    func testParseURLWithEncoding() {
        let string = "scheme://us%2Fer:pass%2Fword@ho%2Fst/pa%3Fth/1/2/3?query=%2F&b#fra%2Fgment"
        let url = URL(string: string)!
        XCTAssertEqual(URLComponents.parse(url), URLComponents(string: string)!)
    }

    func testParseURLWithRecursion() {
        let string = "scheme://h/p?u=https%3A%2F%2Fh%3Fu%3Dhttps%253A%252F%252Fh%253Fa%253Db%2526b%253Dc"
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

    func testOriginIsCalendar() {
        var url = URLComponents.parse("https://foobar.com/courses/165/assignments/900/submissions/1")
        XCTAssertFalse(url.originIsCalendar)

        url = URLComponents.parse("/submissions/1?origin=calendar&origin=bogus")
        XCTAssertTrue(url.originIsCalendar)
    }

    func testOriginIsNotification() {
        var url = URLComponents.parse("https://foobar.com/courses/165/assignments/900/submissions/1")
        XCTAssertFalse(url.originIsNotification)

        url.originIsNotification = true
        XCTAssertTrue(url.originIsNotification)

        XCTAssertEqual(url.url?.absoluteString, "https://foobar.com/courses/165/assignments/900/submissions/1?origin=notification")

        url.originIsNotification = false
        XCTAssertEqual(url.url?.absoluteString, "https://foobar.com/courses/165/assignments/900/submissions/1?")
    }

    func testOriginIsModuleItemDetails() {
        var url = URLComponents.parse("/courses/165/assignments/900")
        XCTAssertFalse(url.originIsModuleItemDetails)

        url = URLComponents.parse("/courses/165/assignments/900?origin=calendar&origin=module_item_details")
        XCTAssertTrue(url.originIsModuleItemDetails)
    }

    func testPageQueryValue() {
        var testee = URLComponents.parse("/courses/165/assignments/900?page=3")
        XCTAssertEqual(testee.page, 3)

        testee = URLComponents.parse("/courses/165/assignments/900")
        XCTAssertEqual(testee.page, 1)
    }

    func testPageSizeQueryValue() {
        var testee = URLComponents.parse("/courses/165/assignments/900?per_page=100")
        XCTAssertEqual(testee.pageSize, 100)

        testee = URLComponents.parse("/courses/165/assignments/900")
        XCTAssertNil(testee.pageSize)
    }

    func testContextColor() {
        let testee = URLComponents.parse("/empty?contextColor=001122")
        XCTAssertEqual(testee.contextColor, UIColor(hexString: "#001122"))
    }
}
