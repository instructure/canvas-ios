//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

class GradingSchemeTests: CoreTestCase {

    func testScoreConversion() {
        let entries: [GradingSchemeEntry] = {
            let entryA: GradingSchemeEntry = databaseClient.insert()
            entryA.name = "A"
            entryA.value = 0.9
            let entryB: GradingSchemeEntry = databaseClient.insert()
            entryB.name = "B"
            entryB.value = 0.3
            let entryF: GradingSchemeEntry = databaseClient.insert()
            entryF.name = "F"
            entryF.value = 0
            return [entryA, entryB, entryF]
        }()

        let testee = GradingScheme(pointsBased: false, scaleFactor: 1, entries: entries)

        var result = testee.convertScoreToLetterGrade(score: 90)
        XCTAssertEqual(result, "A")

        result = testee.convertScoreToLetterGrade(score: 89)
        XCTAssertEqual(result, "B")

        result = testee.convertScoreToLetterGrade(score: 0)
        XCTAssertEqual(result, "F")
    }

    func testScoreConversionWithEmptyScheme() {
        let testee = GradingScheme.empty
        let result = testee.convertScoreToLetterGrade(score: 30)
        XCTAssertNil(result)
    }

    func testScoreConversionWithInvalidScheme() {
        let entries: [GradingSchemeEntry] = {
            let entry: GradingSchemeEntry = databaseClient.insert()
            entry.name = "A"
            entry.value = 90
            return [entry]
        }()

        let testee = GradingScheme(pointsBased: false, scaleFactor: 1, entries: entries)
        let result = testee.convertScoreToLetterGrade(score: 30)

        XCTAssertNil(result)
    }

    func testFormattedScorePointBasedOn() {
        let testee = GradingScheme(pointsBased: true, scaleFactor: 5, entries: [])

        var result = testee.formattedScore(from: 80)
        XCTAssertEqual(result, "4")

        result = testee.formattedScore(from: 45.76)
        XCTAssertEqual(result, "2.29")

        result = testee.formattedScore(from: 33.43)
        XCTAssertEqual(result, "1.67")
    }

    func testFormattedScorePointBasedOff() {
        let testee = GradingScheme(pointsBased: false, scaleFactor: 5, entries: [])

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
