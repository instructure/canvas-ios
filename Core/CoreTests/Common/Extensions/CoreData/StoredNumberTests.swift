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

class StoredNumberTests: CoreTestCase {

    private static let testData = (
        doubleValue: 42.5,
        intValue: 123
    )
    private lazy var testData = Self.testData

    // MARK: - CDStoredDouble

    func test_decodeDouble() {
        let nsNumber = NSNumber(value: testData.doubleValue)

        var result = CDStoredDouble<TestEntity>.decode(nsNumber)
        XCTAssertEqual(result, testData.doubleValue)

        result = CDStoredDouble<TestEntity>.decode(nil)
        XCTAssertEqual(result, nil)
    }

    func test_encodeDouble() {
        var result = CDStoredDouble<TestEntity>.encode(testData.doubleValue)
        XCTAssertEqual(result?.doubleValue, testData.doubleValue)

        result = CDStoredDouble<TestEntity>.encode(nil)
        XCTAssertEqual(result, nil)
    }

    // MARK: - CDStoredInt

    func test_decodeInt() {
        let nsNumber = NSNumber(value: testData.intValue)

        var result = CDStoredInt<TestEntity>.decode(nsNumber)
        XCTAssertEqual(result, testData.intValue)

        result = CDStoredInt<TestEntity>.decode(nil)
        XCTAssertEqual(result, nil)
    }

    func test_encodeInt() {
        var result = CDStoredInt<TestEntity>.encode(testData.intValue)
        XCTAssertEqual(result?.intValue, testData.intValue)

        result = CDStoredInt<TestEntity>.encode(nil)
        XCTAssertEqual(result, nil)
    }
}

// MARK: - Test Entity

private final class TestEntity: NSManagedObject { }
