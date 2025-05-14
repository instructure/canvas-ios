//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Foundation
import TestsFoundation
@testable import Core
import XCTest

class DeferredValueTests: CoreTestCase {

    func test_equality() throws {
        // Given
        let value1 = DeferredValue(value: 5)
        var value2 = DeferredValue(value: 5)

        // Then
        XCTAssertEqual(value1, value2)

        // When
        value2.deferred = 2

        // Then
        XCTAssertEqual(value1, value2)

        // When
        value2.update()

        // Then
        XCTAssertNotEqual(value1, value2)
    }

    func test_updating() throws {
        // Given
        var deferredValue = DeferredValue(value: "Demo")

        // Then
        XCTAssertEqual(deferredValue.value, "Demo")

        // When
        deferredValue.deferred = "Example"

        // Then
        XCTAssertEqual(deferredValue.value, "Demo")

        // When
        deferredValue.update()

        // Then
        XCTAssertEqual(deferredValue.value, "Example")
    }
}
