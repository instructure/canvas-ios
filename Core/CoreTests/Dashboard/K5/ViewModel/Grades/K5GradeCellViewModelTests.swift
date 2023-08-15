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

import XCTest
import SwiftUI
@testable import Core

class K5GradeCellViewModelTests: CoreTestCase {

    func testDefaultK5Color() {
        let testee = K5GradeCellViewModel(title: "ART", imageURL: nil, grade: nil, score: 55, color: nil, courseID: "", hideGradeBar: false)
        XCTAssertEqual(testee.color, .oxford)
    }

    func testGradePercentage() {
        let testee = K5GradeCellViewModel(title: "ART", imageURL: nil, grade: "55", score: 55, color: nil, courseID: "", hideGradeBar: false)
        XCTAssertEqual(testee.gradePercentage, 55)
    }

    func testGradePercentageWithoutScore() {
        let testee = K5GradeCellViewModel(title: "ART", imageURL: nil, grade: "B", score: nil, color: nil, courseID: "", hideGradeBar: false)
        XCTAssertEqual(testee.gradePercentage, 0)
    }

    func testRoundedDisplayGrade() {
        let testee = K5GradeCellViewModel(title: "ART", imageURL: nil, grade: "A", score: 99.9, color: nil, courseID: "", hideGradeBar: false)
        XCTAssertEqual(testee.roundedDisplayGrade, "100%")
    }

    func testRoute() {
        let testee = K5GradeCellViewModel(title: "ART", imageURL: nil, grade: "A", score: 99.9, color: nil, courseID: "66", hideGradeBar: false)
        XCTAssertEqual(testee.route, "/courses/66#grades")
    }
}
