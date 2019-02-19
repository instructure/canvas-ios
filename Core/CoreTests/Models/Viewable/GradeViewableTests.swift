//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Core

class GradeViewableTests: XCTestCase {
    struct Model: GradeViewable {
        let gradingType: GradingType
        let pointsPossible: Double?
        let viewableGrade: String?
        let viewableScore: Double?

        init(
            gradingType: GradingType = .points,
            pointsPossible: Double? = 100.0,
            viewableGrade: String? = nil,
            viewableScore: Double? = nil
        ) {
            self.gradingType = gradingType
            self.pointsPossible = pointsPossible
            self.viewableGrade = viewableGrade
            self.viewableScore = viewableScore
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
        XCTAssertEqual(Model(pointsPossible: 100, viewableScore: 10).scoreOutOfPointsPossibleText, "10 out of 100 points possible")
        XCTAssertEqual(Model(pointsPossible: 1, viewableScore: 1).scoreOutOfPointsPossibleText, "1 out of 1 point possible")
    }

    func testGradeText() {
        XCTAssertNil(Model(gradingType: .letter_grade, viewableGrade: nil).gradeText)
        XCTAssertEqual(Model(gradingType: .letter_grade, viewableGrade: "B+").gradeText, "B+")
        XCTAssertEqual(Model(gradingType: .percent, viewableGrade: "80%").gradeText, "80%")
        XCTAssertEqual(Model(gradingType: .points, viewableGrade: "80").gradeText, "80")
        XCTAssertNil(Model(gradingType: .not_graded).gradeText)
        XCTAssertNil(Model(gradingType: .gpa_scale).gradeText)
        XCTAssertEqual(Model(gradingType: .gpa_scale, viewableGrade: "3.0").gradeText, "3.0 GPA")
        XCTAssertNil(Model(gradingType: .pass_fail).gradeText)
        XCTAssertEqual(Model(gradingType: .pass_fail, viewableScore: 0).gradeText, "Incomplete")
        XCTAssertEqual(Model(gradingType: .pass_fail, viewableScore: 100).gradeText, "Complete")
    }

    func testFinalGradeText() {
        XCTAssertNil(Model(gradingType: .points).finalGradeText)
        XCTAssertEqual(Model(gradingType: .points, viewableScore: 1).finalGradeText, "Final Grade: 1 pt")
        XCTAssertEqual(Model(gradingType: .points, viewableScore: 5).finalGradeText, "Final Grade: 5 pts")
        XCTAssertEqual(Model(gradingType: .gpa_scale, viewableGrade: "A").finalGradeText, "Final Grade: A")
        XCTAssertNil(Model(gradingType: .gpa_scale).finalGradeText)
    }
}
