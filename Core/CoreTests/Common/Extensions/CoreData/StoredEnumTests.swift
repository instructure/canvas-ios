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

class StoredEnumTests: CoreTestCase {

    private enum TestEnum: String {
        case first
        case second
    }

    // MARK: - CDStoredEnum

    func test_decodeEnum() {
        var result = CDStoredEnum<TestEntity, TestEnum>.decode("first")
        XCTAssertEqual(result, .first)

        result = CDStoredEnum<TestEntity, TestEnum>.decode("invalid")
        XCTAssertEqual(result, nil)

        result = CDStoredEnum<TestEntity, TestEnum>.decode(nil)
        XCTAssertEqual(result, nil)
    }

    func test_encodeEnum() {
        var result = CDStoredEnum<TestEntity, TestEnum>.encode(.first)
        XCTAssertEqual(result, "first")

        result = CDStoredEnum<TestEntity, TestEnum>.encode(nil)
        XCTAssertEqual(result, nil)
    }

    // MARK: - CDStoredEnumWithDefault

    func test_decodeEnumWithDefault() {
        var result = CDStoredEnumWithDefault<TestEntity, TestEnum>.decode("first")
        XCTAssertEqual(result, .first)

        result = CDStoredEnumWithDefault<TestEntity, TestEnum>.decode("invalid")
        XCTAssertEqual(result, nil)

        result = CDStoredEnumWithDefault<TestEntity, TestEnum>.decode(nil)
        XCTAssertEqual(result, nil)
    }

    func test_encodeEnumWithDefault() {
        let result = CDStoredEnumWithDefault<TestEntity, TestEnum>.encode(.first)
        XCTAssertEqual(result, "first")
    }
}

// MARK: - Test Entity

private final class TestEntity: NSManagedObject { }
