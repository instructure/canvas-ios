//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class StringLocalizedFormatsTests: XCTestCase {

    func test_format_attemptNumber() {
        XCTAssertEqual(String.format(attemptNumber: 1), "Attempt 1")
        XCTAssertEqual(String.format(attemptNumber: 5), "Attempt 5")
        XCTAssertEqual(String.format(attemptNumber: 0), "Attempt 0")
    }

    func test_format_numberOfItems() {
        XCTAssertEqual(String.format(numberOfItems: 1), "1 item")
        XCTAssertEqual(String.format(numberOfItems: 5), "5 items")
        XCTAssertEqual(String.format(numberOfItems: 0), "0 items")

        let optionalValue: Int? = 5
        XCTAssertEqual(String.format(numberOfItems: optionalValue), "5 items")
        XCTAssertEqual(String.format(numberOfItems: nil), nil)
    }

    func test_format_accessibilityListCount() {
        XCTAssertEqual(String.format(accessibilityListCount: 1), "List, 1 item")
        XCTAssertEqual(String.format(accessibilityListCount: 5), "List, 5 items")
        XCTAssertEqual(String.format(accessibilityListCount: 0), "List, 0 items")
    }

    func test_format_pts() {
        XCTAssertEqual(String.format(pts: 1), "1 pt")
        XCTAssertEqual(String.format(pts: 5), "5 pts")
        XCTAssertEqual(String.format(pts: 0), "0 pts")
        XCTAssertEqual(String.format(pts: 12.345678), "12.3457 pts")

        let optionalValue: Double? = 5
        XCTAssertEqual(String.format(pts: optionalValue), "5 pts")
        XCTAssertEqual(String.format(pts: nil), nil)
    }

    func test_format_points() {
        XCTAssertEqual(String.format(points: 1), "1 point")
        XCTAssertEqual(String.format(points: 5), "5 points")
        XCTAssertEqual(String.format(points: 0), "0 points")
        XCTAssertEqual(String.format(points: 12.345678), "12.3457 points")

        let optionalValue: Double? = 5
        XCTAssertEqual(String.format(points: optionalValue), "5 points")
        XCTAssertEqual(String.format(points: nil), nil)
    }

    func test_format_accessibilityErrorMessage() {
        XCTAssertEqual(String.format(accessibilityErrorMessage: "Some error description"), "Error: Some error description")
        XCTAssertEqual(String.format(accessibilityErrorMessage: ""), "Error: ")

        let optionalValue: String? = "Some error description"
        XCTAssertEqual(String.format(accessibilityErrorMessage: optionalValue), "Error: Some error description")
        XCTAssertEqual(String.format(accessibilityErrorMessage: nil), nil)
    }
}
