//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
        a.submission = Submission.make(from: .make(workflow_state: .unsubmitted))
        view.update(a)
        XCTAssertTrue(view.isHidden)
    }

    func testItHidesWhenNoGrade() {
        let a = Assignment.make()
        a.submission = Submission.make(from: .make(
            grade: nil,
            workflow_state: .submitted
        ))
        view.update(a)
        XCTAssertTrue(view.isHidden)
    }

    func testItShowsCorrectViewsForPassFail() {
        let a = Assignment.make(from: .make(grading_type: .pass_fail))
        a.submission = Submission.make(from: .make(
            grade: "complete",
            workflow_state: .graded
        ))
        view.update(a)
        XCTAssertTrue(view.circlePoints.isHidden)
        XCTAssertTrue(view.circleLabel.isHidden)
        XCTAssertFalse(view.circleComplete.isHidden)
        XCTAssertTrue(view.circleComplete.image == UIImage.checkSolid)

        a.submission?.grade = "incomplete"
        view.update(a)
        XCTAssertFalse(view.circleComplete.isHidden)
        XCTAssertTrue(view.circleComplete.image == UIImage.xLine)
    }

    func testItShowsCorrectViewsForNonPassFail() {
        let a = Assignment.make(from: .make(grading_type: .points))
        a.submission = Submission.make(from: .make(
            grade: "10",
            score: 10,
            workflow_state: .graded
        ))
        view.update(a)
        XCTAssertFalse(view.circlePoints.isHidden)
        XCTAssertFalse(view.circleLabel.isHidden)
        XCTAssertTrue(view.circleComplete.isHidden)
    }

    func testItUpdatesCircle() {
        let a = Assignment.make(from: .make(
            grading_type: .points,
            points_possible: 100
        ))
        a.submission = Submission.make(from: .make(
            grade: "80",
            score: 80,
            workflow_state: .graded
        ))
        view.update(a)
        XCTAssertEqual(view.circlePoints.text, "80")
        XCTAssertEqual(view.gradeCircle?.progress, 0.8)
        XCTAssertEqual(view.gradeCircle?.accessibilityLabel, "Scored 80 out of 100 points possible")
    }

    func testItShowsLatePenalty() {
        let a = Assignment.make(from: .make(
            grading_type: .points,
            points_possible: 100
        ))
        a.submission = Submission.make(from: .make(
            grade: "80",
            late: true,
            points_deducted: 10,
            score: 80,
            workflow_state: .graded
        ))
        view.update(a)
        XCTAssertFalse(view.latePenaltyLabel.isHidden)
        XCTAssertFalse(view.finalGradeLabel.isHidden)
        XCTAssertEqual(view.latePenaltyLabel.text, "Late penalty (-10 pts)")
        XCTAssertEqual(view.finalGradeLabel.text, "Final Grade: 80 pts")
    }

    func testDisplayGrade() {
        let a = Assignment.make(from: .make(
            grading_type: .points,
            points_possible: 100
        ))
        a.submission = Submission.make(from: .make(
            grade: "80",
            score: 80,
            workflow_state: .graded
        ))
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
        let a = Assignment.make(from: .make(
            grading_type: .points,
            points_possible: 100
        ))
        a.submission = Submission.make(from: .make(
            grade: "80",
            score: 80,
            workflow_state: .graded
        ))
        view.update(a)
        XCTAssertEqual(view.circleLabel.text, "Points")
        XCTAssertEqual(view.outOfLabel.text, "Out of 100 pts")
        XCTAssertTrue(view.latePenaltyLabel.isHidden)
        XCTAssertTrue(view.finalGradeLabel.isHidden)
    }

    func testItRendersForExcused() {
        let a = Assignment.make(from: .make(
            submission: .make(excused: true)
        ))
        view.update(a)
        XCTAssertFalse(view.isHidden)
        XCTAssertTrue(view.circlePoints.isHidden)
        XCTAssertTrue(view.circleLabel.isHidden)
        XCTAssertFalse(view.circleComplete.isHidden)
        XCTAssertEqual(view.gradeCircle?.progress, 1)
        XCTAssertFalse(view.displayGrade.isHidden)
        XCTAssertEqual(view.displayGrade.text, "Excused")
    }

    func testItRendersScoreWhenNoPointsIsPossible() {
        let a = Assignment.make(from: .make(grading_type: .points,
                                            points_possible: nil,
                                            submission: .make(grade: "77",
                                                              score: 77,
                                                              workflow_state: .graded)
        ))
        view.update(a)
        XCTAssertFalse(view.isHidden)
        XCTAssertFalse(view.circlePoints.isHidden)
        XCTAssertEqual(view.circlePoints.text, "77")
        XCTAssertFalse(view.circleLabel.isHidden)
        XCTAssertTrue(view.circleComplete.isHidden)
        XCTAssertEqual(view.gradeCircle?.progress, 1)
        XCTAssertEqual(view.gradeCircle?.accessibilityLabel, "77.0 Points")
        XCTAssertTrue(view.displayGrade.isHidden)
        XCTAssertEqual(view.displayGrade.text, "77")
    }
}
