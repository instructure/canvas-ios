//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
@testable import Core

class GradeCircleViewTests: XCTestCase {
    var view: GradeCircleView!

    override func setUp() {
        super.setUp()
        view = GradeCircleView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }

    func testItHidesWhenNoSubmission() {
        let a = Assignment.make()
        view.update(a)
        XCTAssertTrue(view.isHidden)
    }

    func testItHidesWhenSubmissionIsUnsubmitted() {
        let a = Assignment.make()
        a.submission = Submission.make(["workflowStateRaw": "unsubmitted"])
        view.update(a)
        XCTAssertTrue(view.isHidden)
    }

    func testItHidesWhenNoGrade() {
        let a = Assignment.make()
        a.submission = Submission.make([
            "workflowStateRaw": "submitted",
            "grade": nil,
        ])
        view.update(a)
        XCTAssertTrue(view.isHidden)
    }

    func testItShowsCorrectViewsForPassFail() {
        let a = Assignment.make(["gradingTypeRaw": "pass_fail"])
        a.submission = Submission.make([
            "workflowStateRaw": "graded",
            "grade": "Complete",
            "scoreRaw": nil,
        ])
        view.update(a)
        XCTAssertTrue(view.circlePoints.isHidden)
        XCTAssertTrue(view.circleLabel.isHidden)
        XCTAssertTrue(view.circleComplete.isHidden)

        a.submission?.score = 10
        view.update(a)
        XCTAssertFalse(view.circleComplete.isHidden)

        a.submission?.score = 0
        view.update(a)
        XCTAssertTrue(view.circleComplete.isHidden)
    }

    func testItShowsCorrectViewsForNonPassFail() {
        let a = Assignment.make(["gradingTypeRaw": "points"])
        a.submission = Submission.make([
            "workflowStateRaw": "graded",
            "grade": "10",
            "scoreRaw": 10,
        ])
        view.update(a)
        XCTAssertFalse(view.circlePoints.isHidden)
        XCTAssertFalse(view.circleLabel.isHidden)
        XCTAssertTrue(view.circleComplete.isHidden)
    }

    func testItUpdatesCircle() {
        let a = Assignment.make([
            "gradingTypeRaw": "points",
            "pointsPossibleRaw": 100,
        ])
        a.submission = Submission.make([
            "workflowStateRaw": "graded",
            "scoreRaw": 80,
            "grade": "80",
        ])
        view.update(a)
        XCTAssertEqual(view.circlePoints.text, "80")
        XCTAssertEqual(view.gradeCircle?.progress, 0.8)
        XCTAssertEqual(view.gradeCircle?.accessibilityLabel, "80 out of 100 points possible")
    }

    func testItShowsLatePenalty() {
        let a = Assignment.make([
            "gradingTypeRaw": "points",
            "pointsPossibleRaw": 100,
        ])
        a.submission = Submission.make([
            "workflowStateRaw": "graded",
            "scoreRaw": 80,
            "grade": "80",
            "late": true,
            "pointsDeductedRaw": 10,
        ])
        view.update(a)
        XCTAssertFalse(view.latePenaltyLabel.isHidden)
        XCTAssertFalse(view.finalGradeLabel.isHidden)
        XCTAssertEqual(view.latePenaltyLabel.text, "Late penalty (-10 pts)")
        XCTAssertEqual(view.finalGradeLabel.text, "Final Grade: 80 pts")
    }

    func testDisplayGrade() {
        let a = Assignment.make([
            "gradingTypeRaw": "points",
            "pointsPossibleRaw": 100,
        ])
        a.submission = Submission.make([
            "workflowStateRaw": "graded",
            "scoreRaw": 80,
            "grade": "80",
        ])
        view.update(a)
        XCTAssertTrue(view.displayGrade.isHidden)

        a.gradingType = .gpa_scale
        a.submission?.grade = "3.8"
        view.update(a)
        XCTAssertFalse(view.displayGrade.isHidden)
        XCTAssertEqual(view.displayGrade.text, "3.8 GPA")

        a.submission?.late = true
        view.update(a)
        XCTAssertTrue(view.displayGrade.isHidden)
    }

    func testItRendersGradeInformation() {
        let a = Assignment.make([
            "gradingTypeRaw": "points",
            "pointsPossibleRaw": 100,
        ])
        a.submission = Submission.make([
            "workflowStateRaw": "graded",
            "scoreRaw": 80,
            "grade": "80",
        ])
        view.update(a)
        XCTAssertEqual(view.circleLabel.text, "Points")
        XCTAssertEqual(view.outOfLabel.text, "Out of 100 pts")
        XCTAssertTrue(view.latePenaltyLabel.isHidden)
        XCTAssertTrue(view.finalGradeLabel.isHidden)
    }
}
