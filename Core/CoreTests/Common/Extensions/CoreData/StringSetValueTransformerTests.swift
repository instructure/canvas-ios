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

class StringSetValueTransformerTests: XCTestCase {
    func testTransformedValue() {
        let transformer = StringSetValueTransformer()
        let stringSet: Set<String> = ["apple", "banana", "cherry"]

        let data = transformer.transformedValue(stringSet) as? Data
        XCTAssertNotNil(data)
    }

    func testTransformedValueWithEmptySet() {
        let transformer = StringSetValueTransformer()
        let stringSet: Set<String> = []

        let data = transformer.transformedValue(stringSet) as? Data
        XCTAssertNotNil(data)
    }

    func testTransformedValueWithNil() {
        let transformer = StringSetValueTransformer()

        let data = transformer.transformedValue(nil)
        XCTAssertNil(data)
    }

    func testTransformedValueWithWrongType() {
        let transformer = StringSetValueTransformer()

        let data = transformer.transformedValue("not a set")
        XCTAssertNil(data)
    }

    func testReverseTransformedValue() {
        let transformer = StringSetValueTransformer()
        let originalSet: Set<String> = ["apple", "banana", "cherry"]

        let data = transformer.transformedValue(originalSet) as? Data
        XCTAssertNotNil(data)

        let reversedSet = transformer.reverseTransformedValue(data) as? Set<String>
        XCTAssertEqual(reversedSet, originalSet)
    }

    func testReverseTransformedValueWithEmptySet() {
        let transformer = StringSetValueTransformer()
        let originalSet: Set<String> = []

        let data = transformer.transformedValue(originalSet) as? Data
        XCTAssertNotNil(data)

        let reversedSet = transformer.reverseTransformedValue(data) as? Set<String>
        XCTAssertEqual(reversedSet, originalSet)
    }

    func testReverseTransformedValueWithNil() {
        let transformer = StringSetValueTransformer()

        let reversedSet = transformer.reverseTransformedValue(nil)
        XCTAssertNil(reversedSet)
    }

    func testReverseTransformedValueWithWrongType() {
        let transformer = StringSetValueTransformer()

        let reversedSet = transformer.reverseTransformedValue("not data")
        XCTAssertNil(reversedSet)
    }

    func testRegistration() {
        StringSetValueTransformer.register()

        let registeredTransformer = ValueTransformer(forName: StringSetValueTransformer.name)
        XCTAssertNotNil(registeredTransformer)
        XCTAssertTrue(registeredTransformer is StringSetValueTransformer)
    }
}
