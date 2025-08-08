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

class PercentageBasedGradingSchemeTests: GradingSchemeTestCase {

    func testScoreConversion() {
        let testee = PercentageBasedGradingScheme(entries: scoreConversionEntries())

        var result = testee.convertNormalizedScoreToLetterGrade(0.90)
        XCTAssertEqual(result, "A")

        result = testee.convertNormalizedScoreToLetterGrade(0.89)
        XCTAssertEqual(result, "B")

        result = testee.convertNormalizedScoreToLetterGrade(0)
        XCTAssertEqual(result, "F")
    }

    func testScoreConversionWithEmptyScheme() {
        let testee = PercentageBasedGradingScheme.default
        let result = testee.convertNormalizedScoreToLetterGrade(0.30)
        XCTAssertNil(result)
    }

    func testScoreConversionWithInvalidScheme() {
        let testee = PercentageBasedGradingScheme(entries: invalidConversionEntries())
        let result = testee.convertNormalizedScoreToLetterGrade(0.30)

        XCTAssertNil(result)
    }

    func testFormattedScore() {
        let testee = PercentageBasedGradingScheme.default

        var result = testee.formattedScore(from: 80)
        XCTAssertEqual(result, "80%")

        result = testee.formattedScore(from: 45.766777)
        XCTAssertEqual(result, "45.77%")

        result = testee.formattedScore(from: 12.345)
        XCTAssertEqual(result, "12.35%")

        result = testee.formattedScore(from: 33.43)
        XCTAssertEqual(result, "33.43%")

        result = testee.formattedScore(from: 87.40)
        XCTAssertEqual(result, "87.4%")
    }

    func test_formattedMaxValue_shouldAlwaysBe100Percent() {
        var testee = PercentageBasedGradingScheme(entries: scoreConversionEntries())
        XCTAssertEqual(testee.formattedMaxValue, "100%")

        testee = PercentageBasedGradingScheme(entries: [])
        XCTAssertEqual(testee.formattedMaxValue, "100%")
    }

    func test_formattedEntryValue() {
        let testee = PercentageBasedGradingScheme(entries: [])

        XCTAssertEqual(testee.formattedEntryValue(1), "100%")
        XCTAssertEqual(testee.formattedEntryValue(0.42), "42%")
        XCTAssertEqual(testee.formattedEntryValue(0.123456), "12.35%")
        XCTAssertEqual(testee.formattedEntryValue(0), "0%")
    }

    func test_formattedEntries() throws {
        let testee = PercentageBasedGradingScheme(entries: [
            .init(name: "A++", value: 1.23),
            .init(name: "A+", value: 1),
            .init(name: "A", value: 0.42),
            .init(name: "B", value: 0.123456),
            .init(name: "F", value: 0.01),
            .init(name: "F-", value: 0.0)
        ])

        guard testee.formattedEntries.count == 6 else { throw InvalidCountError() }

        XCTAssertEqual(testee.formattedEntries[0].name, "A++")
        XCTAssertEqual(testee.formattedEntries[1].name, "A+")
        XCTAssertEqual(testee.formattedEntries[2].name, "A")
        XCTAssertEqual(testee.formattedEntries[3].name, "B")
        XCTAssertEqual(testee.formattedEntries[4].name, "F")
        XCTAssertEqual(testee.formattedEntries[5].name, "F-")

        XCTAssertEqual(testee.formattedEntries[0].value, "123%")
        XCTAssertEqual(testee.formattedEntries[1].value, "100%")
        XCTAssertEqual(testee.formattedEntries[2].value, "42%")
        XCTAssertEqual(testee.formattedEntries[3].value, "12.35%")
        XCTAssertEqual(testee.formattedEntries[4].value, "1%")
        XCTAssertEqual(testee.formattedEntries[5].value, "0%")
    }
}
