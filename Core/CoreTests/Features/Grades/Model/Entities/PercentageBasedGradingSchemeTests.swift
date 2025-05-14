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

    func testFormattedScorePointBasedOff() {
        let testee = PercentageBasedGradingScheme.default

        var result = testee.formattedScore(from: 80)
        XCTAssertEqual(result, "80%")

        result = testee.formattedScore(from: 45.766777)
        XCTAssertEqual(result, "45.766%")

        result = testee.formattedScore(from: 33.43)
        XCTAssertEqual(result, "33.43%")

        result = testee.formattedScore(from: 87.40)
        XCTAssertEqual(result, "87.4%")
    }
}
