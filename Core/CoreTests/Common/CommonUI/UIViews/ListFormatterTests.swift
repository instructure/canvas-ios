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
@testable import Core

class ListFormatterTests: XCTestCase {
    func testLocalizedStringAnd() {
        XCTAssertEqual(ListFormatter.localizedString(from: []), "")
        XCTAssertEqual(ListFormatter.localizedString(from: ["a"]), "a")
        XCTAssertEqual(ListFormatter.localizedString(from: ["a", "b"]), "a and b")
        XCTAssertEqual(ListFormatter.localizedString(from: ["a", "b", "c"]), "a, b, and c")
        XCTAssertEqual(ListFormatter.localizedString(from: ["a", "b", "c", "d"]), "a, b, c, and d")
    }

    func testLocalizedStringOr() {
        XCTAssertEqual(ListFormatter.localizedString(from: [], conjunction: .or), "")
        XCTAssertEqual(ListFormatter.localizedString(from: ["a"], conjunction: .or), "a")
        XCTAssertEqual(ListFormatter.localizedString(from: ["a", "b"], conjunction: .or), "a or b")
        XCTAssertEqual(ListFormatter.localizedString(from: ["a", "b", "c"], conjunction: .or), "a, b, or c")
        XCTAssertEqual(ListFormatter.localizedString(from: ["a", "b", "c", "d"], conjunction: .or), "a, b, c, or d")
    }
}
