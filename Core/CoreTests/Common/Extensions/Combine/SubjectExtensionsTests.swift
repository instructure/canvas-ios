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
import Combine
import XCTest

class SubjectExtensionsTests: XCTestCase {

    func test_binding_returnsCurrentValue() {
        let subject = CurrentValueSubject<Int, Never>(42)

        // WHEN
        let binding = subject.binding

        // THEN
        XCTAssertEqual(binding.wrappedValue, 42)
    }

    func test_binding_updatesSubjectValue() {
        let subject = CurrentValueSubject<String, Never>("initial")
        let binding = subject.binding

        // WHEN
        binding.wrappedValue = "updated"

        // THEN
        XCTAssertEqual(subject.value, "updated")
    }

    func test_binding_worksWithComplexType() {
        struct TestModel {
            var name: String
            var count: Int
        }

        let initialModel = TestModel(name: "test", count: 5)
        let subject = CurrentValueSubject<TestModel, Never>(initialModel)
        let binding = subject.binding

        XCTAssertEqual(binding.wrappedValue.name, "test")
        XCTAssertEqual(binding.wrappedValue.count, 5)

        // WHEN
        let updatedModel = TestModel(name: "updated", count: 10)
        binding.wrappedValue = updatedModel

        // THEN
        XCTAssertEqual(subject.value.name, "updated")
        XCTAssertEqual(subject.value.count, 10)
    }

    func test_binding_worksWithBooleanValue() {
        let subject = CurrentValueSubject<Bool, Never>(false)
        let binding = subject.binding

        XCTAssertFalse(binding.wrappedValue)

        // WHEN
        binding.wrappedValue = true

        // THEN
        XCTAssertTrue(subject.value)
    }

    func test_binding_worksWithOptionalValue() {
        let subject = CurrentValueSubject<Int?, Never>(nil)
        let binding = subject.binding

        XCTAssertNil(binding.wrappedValue)

        // WHEN
        binding.wrappedValue = 100

        // THEN
        XCTAssertEqual(subject.value, 100)

        // WHEN
        binding.wrappedValue = nil

        // THEN
        XCTAssertNil(subject.value)
    }
}
