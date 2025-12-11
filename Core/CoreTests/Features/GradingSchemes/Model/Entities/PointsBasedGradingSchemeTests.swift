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
import TestsFoundation
import XCTest

class PointsBasedGradingSchemeTests: GradingSchemeTestCase {

    func testScoreConversion() {
        let testee = PointsBasedGradingScheme(entries: scoreConversionEntries(), scaleFactor: 5)

        var result = testee.convertNormalizedScoreToLetterGrade(0.90)
        XCTAssertEqual(result, "A")

        result = testee.convertNormalizedScoreToLetterGrade(0.89)
        XCTAssertEqual(result, "B")

        result = testee.convertNormalizedScoreToLetterGrade(0)
        XCTAssertEqual(result, "F")

        result = testee.convertNormalizedScoreToLetterGrade(.infinity)
        XCTAssertEqual(result, "A")

        result = testee.convertNormalizedScoreToLetterGrade(-1 * .infinity)
        XCTAssertEqual(result, "F")

        result = testee.convertNormalizedScoreToLetterGrade(.nan)
        XCTAssertNil(result)
    }

    func testScoreConversionWithEmptyScheme() {
        let testee = PointsBasedGradingScheme.default
        let result = testee.convertNormalizedScoreToLetterGrade(0.30)
        XCTAssertNil(result)
    }

    func testScoreConversionWithInvalidScheme() {
        let testee = PointsBasedGradingScheme(entries: invalidConversionEntries(), scaleFactor: 4)
        let result = testee.convertNormalizedScoreToLetterGrade(0.30)
        XCTAssertNil(result)
    }

    func testFormattedScore() {
        let testee = PointsBasedGradingScheme(entries: [], scaleFactor: 5)

        var result = testee.formattedScore(from: 80)
        XCTAssertEqual(result, "4")

        result = testee.formattedScore(from: 45.76)
        XCTAssertEqual(result, "2.29")

        result = testee.formattedScore(from: 33.43)
        XCTAssertEqual(result, "1.67")
    }

    func test_formattedMaxValue_shouldAlwaysBeScaleFactor() {
        var testee = PointsBasedGradingScheme(entries: scoreConversionEntries(), scaleFactor: 4)
        XCTAssertEqual(testee.formattedMaxValue, "4")

        testee = PointsBasedGradingScheme(entries: [], scaleFactor: 4)
        XCTAssertEqual(testee.formattedMaxValue, "4")
    }

    func test_formattedEntryValue() {
        let testee = PointsBasedGradingScheme(entries: [], scaleFactor: 4)

        XCTAssertEqual(testee.formattedEntryValue(1), "4")
        XCTAssertEqual(testee.formattedEntryValue(0.75), "3")
        XCTAssertEqual(testee.formattedEntryValue(0.10125), "0.41")
        XCTAssertEqual(testee.formattedEntryValue(0), "0")
    }

    func test_formattedEntries() throws {
        let testee = PointsBasedGradingScheme(
            entries: [
                .init(name: "A++", value: 1.23),
                .init(name: "A+", value: 1),
                .init(name: "A", value: 0.42),
                .init(name: "B", value: 0.123456),
                .init(name: "F", value: 0.01),
                .init(name: "F-", value: 0.0)
            ],
            scaleFactor: 10
        )

        guard testee.formattedEntries.count == 6 else { throw InvalidCountError() }

        XCTAssertEqual(testee.formattedEntries[0].name, "A++")
        XCTAssertEqual(testee.formattedEntries[1].name, "A+")
        XCTAssertEqual(testee.formattedEntries[2].name, "A")
        XCTAssertEqual(testee.formattedEntries[3].name, "B")
        XCTAssertEqual(testee.formattedEntries[4].name, "F")
        XCTAssertEqual(testee.formattedEntries[5].name, "F-")

        XCTAssertEqual(testee.formattedEntries[0].value, "12.3")
        XCTAssertEqual(testee.formattedEntries[1].value, "10")
        XCTAssertEqual(testee.formattedEntries[2].value, "4.2")
        XCTAssertEqual(testee.formattedEntries[3].value, "1.23")
        XCTAssertEqual(testee.formattedEntries[4].value, "0.1")
        XCTAssertEqual(testee.formattedEntries[5].value, "0")
    }
}
