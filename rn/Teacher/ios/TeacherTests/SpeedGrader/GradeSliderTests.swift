//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import SwiftUI
@testable import Teacher
import TestsFoundation

class GradeSliderTests: TeacherTestCase {

    func testSliderValueRounding() throws {
        let value = 9.0
        let range: ClosedRange<Double> = 0...10.5
        let sliderWidth: CGFloat = 320
        let gradeSlider = GradeSlider(value: .constant(value), range: range, showTooltip: false, tooltipText: Text(verbatim: ""), score: value, possible: range.upperBound)
        var grade = gradeSlider.grade(for: CGFloat(Double(sliderWidth) / range.upperBound * value), in: sliderWidth)
        XCTAssertEqual(grade, value)
        grade = gradeSlider.grade(for: sliderWidth, in: sliderWidth)
        XCTAssertEqual(grade, range.upperBound)
        grade = gradeSlider.grade(for: 0, in: sliderWidth)
        XCTAssertEqual(grade, range.lowerBound)
        grade = gradeSlider.grade(for: -1, in: sliderWidth)
        XCTAssertEqual(grade, range.lowerBound)
        grade = gradeSlider.grade(for: sliderWidth + 1, in: sliderWidth)
        XCTAssertEqual(grade, range.upperBound)
    }

    func testSliderValueEvenRounding() throws {
        let value = 5.0
        let range: ClosedRange<Double> = 0...10
        let sliderWidth: CGFloat = 320
        let gradeSlider = GradeSlider(value: .constant(value), range: range, showTooltip: false, tooltipText: Text(verbatim: ""), score: value, possible: range.upperBound)
        let halfRange = range.upperBound.rounded(.down) / 2
        var grade = gradeSlider.grade(for: sliderWidth/2 + 1, in: sliderWidth)
        XCTAssertEqual(grade, halfRange)
        grade = gradeSlider.grade(for: sliderWidth/2 - 1, in: sliderWidth)
        XCTAssertEqual(grade, halfRange)
    }
}
