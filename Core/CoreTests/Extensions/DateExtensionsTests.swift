//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

class DateExtensionsTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testIsoString() {
        XCTAssertEqual(Date(timeIntervalSince1970: 0).isoString(), "1970-01-01T00:00:00Z")
    }

    func testFromISOString() {
        XCTAssertEqual(Date(fromISOString: "bad wolf"), nil)
        XCTAssertEqual(Date(fromISOString: "1970-01-01T00:00:00Z"), Date(timeIntervalSince1970: 0))
    }

    func testPlusYears() {
        let a = Date(fromISOString: "2019-12-25T14:24:37Z")!
        let b = Date(fromISOString: "2020-12-25T14:24:37Z")!
        let c = Date(fromISOString: "2018-12-25T14:24:37Z")!
        XCTAssertEqual(a.addYears(1), b)
        XCTAssertEqual(a.addYears(-1), c)
    }

    func testRemoveTime() {
        let a = Date(fromISOString: "2019-12-25T14:24:37Z")!
        let expected = Date(fromISOString: "2019-12-25T07:00:00Z")!
        let result = a.removeTime()

        XCTAssertEqual(result, expected)
    }
}
