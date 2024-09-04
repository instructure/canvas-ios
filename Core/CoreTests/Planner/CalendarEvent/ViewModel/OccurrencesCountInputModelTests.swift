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

import XCTest
import SwiftUI
@testable import Core

final class OccurrencesCountInputModelTests: XCTestCase {

    func test_updating() {
        // Given
        let submitted = ClosureBinding(baseValue: 34)
        let model = OccurrencesCountInputModel(submitted: submitted.binding)

        // Then
        XCTAssertEqual(model.value, 0)

        // When
        model.update()

        // Then
        XCTAssertEqual(model.value, 34)
    }

    func test_validation() {
        // Given
        let submitted = ClosureBinding(baseValue: 0)
        let model = OccurrencesCountInputModel(submitted: submitted.binding)

        // When
        model.value = 300

        // Then
        XCTAssertEqual(model.isValid, true)

        // When
        model.value = 500

        // Then
        XCTAssertEqual(model.isValid, false)

        // When
        model.value = -2

        // Then
        XCTAssertEqual(model.isValid, false)
    }

    func test_submission() {
        // Given
        let submitted = ClosureBinding(baseValue: 0)
        let model = OccurrencesCountInputModel(submitted: submitted.binding)

        // When
        model.value = 237

        // Then
        XCTAssertEqual(model.submittedCount.wrappedValue, 0)
        XCTAssertEqual(model.isValid, true)

        // When
        model.submit()

        // Then
        XCTAssertEqual(submitted.baseValue, 237)

        // When
        model.value = -100
        model.submit()

        // Then
        XCTAssertEqual(model.isValid, false)
        XCTAssertEqual(submitted.baseValue, 237)
    }
}

private class ClosureBinding<Value> {

    private(set) var baseValue: Value
    private(set) lazy var binding = Binding {
        self.baseValue
    } set: { newValue in
        self.baseValue = newValue
    }

    init(baseValue: Value) {
        self.baseValue = baseValue
    }
}
