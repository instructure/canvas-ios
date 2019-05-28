//
// Copyright (C) 2019-present Instructure, Inc.
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
            grade: "Complete",
            score: nil,
            workflow_state: .graded
        ))
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
            points_possible: 100,
            grading_type: .points
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
            points_possible: 100,
            grading_type: .points
        ))
        a.submission = Submission.make(from: .make(
            grade: "80",
            score: 80,
            late: true,
            workflow_state: .graded,
            points_deducted: 10
        ))
        view.update(a)
        XCTAssertFalse(view.latePenaltyLabel.isHidden)
        XCTAssertFalse(view.finalGradeLabel.isHidden)
        XCTAssertEqual(view.latePenaltyLabel.text, "Late penalty (-10 pts)")
        XCTAssertEqual(view.finalGradeLabel.text, "Final Grade: 80 pts")
    }

    func testDisplayGrade() {
        let a = Assignment.make(from: .make(
            points_possible: 100,
            grading_type: .points
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
            points_possible: 100,
            grading_type: .points
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
}
