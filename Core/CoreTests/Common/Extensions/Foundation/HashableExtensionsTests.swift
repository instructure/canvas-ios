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

@testable import Core
import XCTest

final class HashableExtensionsTests: XCTestCase {
    func test_hashedValue_whenSourceIsSingleValue() {
        let value1 = "some text value 1"
        let value2 = "some text value 2"

        XCTAssertEqual(value1.hashedValue() == value1.hashedValue(), true)
        XCTAssertEqual(value1.hashedValue() != value2.hashedValue(), true)
    }

    func test_hashedValue_whenSourceIsArray() {
        let array1: [any Hashable] = [
            "some text value 1",
            "some text value 2",
            42
        ]
        let array2: [any Hashable] = [
            "some text value 2",
            "some text value 1",
            42
        ]

        XCTAssertEqual(array1.hashedValue() == array1.hashedValue(), true)
        XCTAssertEqual(array1.hashedValue() != array2.hashedValue(), true)
    }
}
