//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class GradeViewableTests: XCTestCase {
    struct Model: GradeViewable {
        let gradingType: GradingType
        let pointsPossible: Double?
        let viewableGrade: String?
        let viewableScore: Double?
        let viewableEnteredScore: Double?

        init(
            gradingType: GradingType = .points,
            pointsPossible: Double? = 100.0,
            viewableGrade: String? = nil,
            viewableScore: Double? = nil,
            viewableEnteredScore: Double? = nil
        ) {
            self.gradingType = gradingType
            self.pointsPossible = pointsPossible
            self.viewableGrade = viewableGrade
            self.viewableScore = viewableScore
            self.viewableEnteredScore = viewableEnteredScore
        }
    }

    func testPointsPossible() {
        XCTAssertEqual(Model(pointsPossible: nil).pointsPossibleText, "Not Graded")
        XCTAssertEqual(Model(pointsPossible: 99999).pointsPossibleText, "99,999 pts")
        XCTAssertEqual(Model(pointsPossible: 0.001).pointsPossibleText, "0.001 pts")
    }

    func testPointsText() {
        XCTAssertNil(Model(viewableScore: nil).pointsText)
        XCTAssertEqual(Model(viewableScore: 1).pointsText, "Point")
        XCTAssertEqual(Model(viewableScore: 2).pointsText, "Points")
    }

    func testOutOfText() {
        XCTAssertNil(Model(pointsPossible: nil).outOfText)
        XCTAssertEqual(Model(pointsPossible: 100).outOfText, "Out of 100 pts")
        XCTAssertEqual(Model(pointsPossible: 1).outOfText, "Out of 1 pt")
    }

    func testScoreOutOfPointsPossibleText() {
        XCTAssertNil(Model(pointsPossible: nil).scoreOutOfPointsPossibleText)
        XCTAssertEqual(Model(pointsPossible: 100, viewableScore: 10).scoreOutOfPointsPossibleText, "Scored 10 out of 100 points possible")
        XCTAssertEqual(Model(pointsPossible: 1, viewableScore: 1).scoreOutOfPointsPossibleText, "Scored 1 out of 1 point possible")
    }

    func testFinalGradeText() {
        XCTAssertNil(Model(gradingType: .points).finalGradeText)
        XCTAssertEqual(Model(gradingType: .points, viewableScore: 1).finalGradeText, "Final Grade: 1 pt")
        XCTAssertEqual(Model(gradingType: .points, viewableScore: 5).finalGradeText, "Final Grade: 5 pts")
        XCTAssertEqual(Model(gradingType: .gpa_scale, viewableGrade: "A").finalGradeText, "Final Grade: A")
        XCTAssertNil(Model(gradingType: .gpa_scale).finalGradeText)
    }

    func testEnteredGradeText() {
        XCTAssertNil(Model(viewableEnteredScore: nil).enteredGradeText)
        XCTAssertEqual(Model(viewableEnteredScore: 1).enteredGradeText, "Your Grade: 1 pt")
        XCTAssertEqual(Model(viewableEnteredScore: 99).enteredGradeText, "Your Grade: 99 pts")
    }
}
