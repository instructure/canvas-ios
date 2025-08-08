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
@testable import Core

class APIGradingSchemeEntryTests: XCTestCase {
    let title: String = "Grading Scheme Entry"
    let value: Double = 1.0
    let calculatedValue: Double = 2.0

    func testInit() {
        let apiGradingSchemeEntry: APIGradingSchemeEntry? = .init(name: title, value: value, calculatedValue: calculatedValue)
        XCTAssertNotNil(apiGradingSchemeEntry)
        XCTAssertEqual(apiGradingSchemeEntry?.name, title)
        XCTAssertEqual(apiGradingSchemeEntry?.value, value)
        XCTAssertEqual(apiGradingSchemeEntry?.calculated_value, calculatedValue)
    }

    func testCourseGradingSchemeInit() {
        let courseGradingScheme: [TypeSafeCodable<String, Double>] = [.init(value1: title, value2: nil), .init(value1: nil, value2: value)]
        let apiGradingSchemeEntry: APIGradingSchemeEntry? = .init(courseGradingScheme: courseGradingScheme)
        XCTAssertNotNil(apiGradingSchemeEntry)
        XCTAssertEqual(apiGradingSchemeEntry?.name, title)
        XCTAssertEqual(apiGradingSchemeEntry?.value, value)
        XCTAssertEqual(apiGradingSchemeEntry?.calculated_value, nil)
    }
}
