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
@testable import Core

class GradingTypeTests: CoreTestCase {

    func testStringProperty() {
        XCTAssertEqual(GradingType.percent.string, "Percentage")
        XCTAssertEqual(GradingType.pass_fail.string, "Complete/Incomplete")
        XCTAssertEqual(GradingType.points.string, "Points")
        XCTAssertEqual(GradingType.letter_grade.string, "Letter Grade")
        XCTAssertEqual(GradingType.gpa_scale.string, "GPA Scale")
        XCTAssertEqual(GradingType.not_graded.string, "Not Graded")
    }

    func testRawValues() {
        XCTAssertEqual(GradingType.percent.rawValue, "percent")
        XCTAssertEqual(GradingType.pass_fail.rawValue, "pass_fail")
        XCTAssertEqual(GradingType.points.rawValue, "points")
        XCTAssertEqual(GradingType.letter_grade.rawValue, "letter_grade")
        XCTAssertEqual(GradingType.gpa_scale.rawValue, "gpa_scale")
        XCTAssertEqual(GradingType.not_graded.rawValue, "not_graded")
    }
}
