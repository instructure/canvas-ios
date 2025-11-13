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

import Foundation
import XCTest
import CoreData
@testable import Core

class StoredArrayTests: CoreTestCase {

    private static let testData = (
        strings: ["item1", "item2", "item3"],
        ints: [1, 2, 3]
    )
    private lazy var testData = Self.testData

    // MARK: - CDStoredArray

    func test_decodeArray() {
        var result = CDStoredArray<TestEntity, String>.decode(NSOrderedSet(array: testData.strings))
        XCTAssertEqual(result, testData.strings)

        result = CDStoredArray<TestEntity, String>.decode(NSOrderedSet())
        XCTAssertEqual(result, [])

        result = CDStoredArray<TestEntity, String>.decode(NSOrderedSet(array: testData.ints))
        XCTAssertEqual(result, nil)

        result = CDStoredArray<TestEntity, String>.decode(nil)
        XCTAssertEqual(result, nil)
    }

    func test_encodeArray() {
        var result = CDStoredArray<TestEntity, String>.encode(testData.strings)
        XCTAssertEqual(result.array as? [String], testData.strings)

        result = CDStoredArray<TestEntity, String>.encode([])
        XCTAssertEqual(result.count, 0)
    }
}

// MARK: - Test Entity

private final class TestEntity: NSManagedObject { }
