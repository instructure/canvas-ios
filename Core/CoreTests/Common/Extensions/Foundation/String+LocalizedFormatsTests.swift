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

    func testLocalizedNumberOfItems() {
        XCTAssertEqual(String.localizedNumberOfItems(1), "1 item")
        XCTAssertEqual(String.localizedNumberOfItems(5), "5 items")
        XCTAssertEqual(String.localizedNumberOfItems(0), "0 items")
    }

    func testLocalizedAccessibilityListCount() {
        XCTAssertEqual(String.localizedAccessibilityListCount(1), "List, 1 item")
        XCTAssertEqual(String.localizedAccessibilityListCount(5), "List, 5 items")
    }

    func testLocalizedAccessibilityErrorMessage() {
        XCTAssertEqual(String.localizedAccessibilityErrorMessage("Some error description"), "Error: Some error description")
        XCTAssertEqual(String.localizedAccessibilityErrorMessage(""), "Error: ")

        var optionalString: String? = "Some error description"
        XCTAssertEqual(String.localizedAccessibilityErrorMessage(optionalString), "Error: Some error description")

        optionalString = nil
        XCTAssertEqual(String.localizedAccessibilityErrorMessage(optionalString), nil)
    }

    func testLocalizedAttemptNumber() {
        XCTAssertEqual(String.localizedAttemptNumber(1), "Attempt 1")
        XCTAssertEqual(String.localizedAttemptNumber(5), "Attempt 5")
    }
}
