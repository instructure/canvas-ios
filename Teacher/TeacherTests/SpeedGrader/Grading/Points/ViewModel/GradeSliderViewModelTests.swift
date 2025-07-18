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
import TestsFoundation
@testable import Teacher

class GradeSliderViewModelTests: TeacherTestCase {

    var viewModel: GradeSliderViewModel!

    override func setUp() {
        super.setUp()
        viewModel = GradeSliderViewModel()
    }

    func test_stepValue_0to10_returnsQuarters() {
        XCTAssertEqual(viewModel.stepValue(for: 5), 0.25)
        XCTAssertEqual(viewModel.stepValue(for: 10), 0.25)
        XCTAssertEqual(viewModel.stepValue(for: 0), 0.25)
    }

    func test_stepValue_10to20_returnsHalves() {
        XCTAssertEqual(viewModel.stepValue(for: 15), 0.5)
        XCTAssertEqual(viewModel.stepValue(for: 20), 0.5)
        XCTAssertEqual(viewModel.stepValue(for: 10.1), 0.5)
    }

    func test_stepValue_above20_returnsWholeNumbers() {
        XCTAssertEqual(viewModel.stepValue(for: 25), 1.0)
        XCTAssertEqual(viewModel.stepValue(for: 100), 1.0)
        XCTAssertEqual(viewModel.stepValue(for: 20.1), 1.0)
    }

    func test_gradeValue_quartersStep_roundsToQuarters() {
        let maxValue: Double = 10

        let quarterValue = viewModel.gradeValue(for: 12.5, in: 100, maxValue: maxValue)
        XCTAssertEqual(quarterValue, 1.25)

        let halfValue = viewModel.gradeValue(for: 37.5, in: 100, maxValue: maxValue)
        XCTAssertEqual(halfValue, 3.75)
    }

    func test_gradeValue_halvesStep_roundsToHalves() {
        let maxValue: Double = 15

        let halfValue = viewModel.gradeValue(for: 33.33, in: 100, maxValue: maxValue)
        XCTAssertEqual(halfValue, 5.0)

        let wholeValue = viewModel.gradeValue(for: 60, in: 100, maxValue: maxValue)
        XCTAssertEqual(wholeValue, 9.0)
    }

    func test_gradeValue_wholeNumbersStep_roundsToWholeNumbers() {
        let maxValue: Double = 50

        let wholeValue = viewModel.gradeValue(for: 44, in: 100, maxValue: maxValue)
        XCTAssertEqual(wholeValue, 22.0)

        let roundedValue = viewModel.gradeValue(for: 45.8, in: 100, maxValue: maxValue)
        XCTAssertEqual(roundedValue, 23.0)
    }

    func test_gradeValue_respectsRangeBounds() {
        let maxValue: Double = 10

        let belowMin = viewModel.gradeValue(for: -10, in: 100, maxValue: maxValue)
        XCTAssertEqual(belowMin, 0.0)

        let aboveMax = viewModel.gradeValue(for: 150, in: 100, maxValue: maxValue)
        XCTAssertEqual(aboveMax, 10.0)
    }

    func test_gradeValue_zeroToMaxValue_worksCorrectly() {
        let maxValue: Double = 5

        let midValue = viewModel.gradeValue(for: 50, in: 100, maxValue: maxValue)
        XCTAssertEqual(midValue, 2.5)
    }

    func test_formatScore_0to10_returns2Decimals() {
        XCTAssertEqual(viewModel.formatScore(5.123, maxPoints: 10), "5.12")
        XCTAssertEqual(viewModel.formatScore(7.5, maxPoints: 5), "7.50")
        XCTAssertEqual(viewModel.formatScore(0, maxPoints: 10), "0.00")
    }

    func test_formatScore_10to20_returns1Decimal() {
        XCTAssertEqual(viewModel.formatScore(15.67, maxPoints: 20), "15.7")
        XCTAssertEqual(viewModel.formatScore(12.3, maxPoints: 15), "12.3")
        XCTAssertEqual(viewModel.formatScore(10, maxPoints: 12), "10.0")
    }

    func test_formatScore_above20_returnsWholeNumbers() {
        XCTAssertEqual(viewModel.formatScore(25.67, maxPoints: 50), "26")
        XCTAssertEqual(viewModel.formatScore(89.1, maxPoints: 100), "89")
        XCTAssertEqual(viewModel.formatScore(42, maxPoints: 25), "42")
    }
}
