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

class GradeStatisticsGraphViewTests: XCTestCase {
    var view: GradeStatisticGraphView!

    override func setUp() {
        super.setUp()
        view = GradeStatisticGraphView(frame: CGRect(x: 0, y: 0, width: 800, height: 200))
    }

    // Helper func to validate the layout
    private func validateLayout(assignment: Assignment, allowedError: CGFloat) {
        guard let scoreStatistics = assignment.scoreStatistics, let maxPossible = assignment.pointsPossible else {
            XCTFail("Tried to validate layout when there were no score statistics")
            return
        }
        XCTAssertFalse(view.isHidden, "GradeStatisticGraphView should not be hidden")

        // Check order of markers
        let x1 = view.minPossibleBar.frame.midX,
            x2 = view.minBarView.frame.midX.rounded(),
            x3 = view.meanBarView.frame.midX.rounded(),
            x4 = view.maxBarView.frame.midX.rounded(),
            x5 = view.maxPossibleBar.frame.midX
        XCTAssertTrue(x1 <= x2 && x2 <= x3 && x3 <= x4 && x4 <= x5, "Graph view text labels were not correctly ordered")

        let minX = view.minPossibleBar.frame.midX
        let width = view.maxPossibleBar.frame.midX - view.minPossibleBar.frame.midX

        let expected = [0, scoreStatistics.min, scoreStatistics.mean, scoreStatistics.max, maxPossible].map { (d: Double) -> CGFloat in
            return CGFloat(d / maxPossible) * width + minX
        }
        XCTAssertLessThan((x1 - expected[0]).magnitude, allowedError, "Min possible label was too far from it's expected location")
        XCTAssertLessThan((x2 - expected[1]).magnitude, allowedError, "Min label was too far from it's expected location")
        XCTAssertLessThan((x3 - expected[2]).magnitude, allowedError, "Avg label was too far from it's expected location")
        XCTAssertLessThan((x4 - expected[3]).magnitude, allowedError, "Max label was too far from it's expected location")
        XCTAssertLessThan((x5 - expected[4]).magnitude, allowedError, "Max possible label was too far from it's expected location")
    }

    // Helper func to call update on the view and then re-layout as if being displayed
    func updateAndValidateLayoutForAssignment(assignment: Assignment, allowedError: CGFloat = 2.0) {
        view.layoutIfNeeded()
        view.update(assignment)

        // This is needed for tests since we aren't actually in a view controller or render loop
        view.setNeedsLayout()
        view.layoutIfNeeded()

        validateLayout(assignment: assignment, allowedError: allowedError)
    }

    func testLabelsCorrectLocationNoPressure() {
        let a = Assignment.make(from: .make(grading_type: .points, points_possible: 10.0, score_statistics: .make(mean: 5.0, min: 2.0, max: 8.0)))
        a.submission = Submission.make(from: .make(
            grade: "6.0",
            score: 6.0,
            workflow_state: .graded
        ))
        updateAndValidateLayoutForAssignment(assignment: a)
    }

    func testLabelsCorrectLocationAllZero() {
        let a = Assignment.make(from: .make(grading_type: .points, points_possible: 10.0, score_statistics: .make(mean: 0.0, min: 0.0, max: 0.0)))
        a.submission = Submission.make(from: .make(
            grade: "0.0",
            score: 0.0,
            workflow_state: .graded
        ))
        updateAndValidateLayoutForAssignment(assignment: a)
    }

    func testLabelsCorrectLocationAllMax() {
        let a = Assignment.make(from: .make(grading_type: .points, points_possible: 10.0, score_statistics: .make(mean: 10.0, min: 10.0, max: 10.0)))
        a.submission = Submission.make(from: .make(
            grade: "10.0",
            score: 10.0,
            workflow_state: .graded
        ))
        updateAndValidateLayoutForAssignment(assignment: a)
    }

    func testLabelsCorrectLocationFullSplit() {
        let a = Assignment.make(from: .make(grading_type: .points, points_possible: 10.0, score_statistics: .make(mean: 0.0, min: 0.0, max: 10.0)))
        a.submission = Submission.make(from: .make(
            grade: "10.0",
            score: 10.0,
            workflow_state: .graded
        ))
        updateAndValidateLayoutForAssignment(assignment: a)
    }

    func testLabelsOutOfBounds() {
        let a = Assignment.make(from: .make(grading_type: .points, points_possible: 10.0, score_statistics: .make(mean: 11.0, min: -5000.0, max: 6000.0)))
        a.submission = Submission.make(from: .make(
            grade: "15.0",
            score: 15.0,
            workflow_state: .graded
        ))

        view.layoutIfNeeded()
        view.update(a)

        // This is needed for tests since we aren't actually in a view controller or render loop
        view.setNeedsLayout()
        view.layoutIfNeeded()

        // Should appear the same as the layout for min=0, max=max_possible, and mean=max_possible
        let lookalike = Assignment.make(from: .make(grading_type: .points, points_possible: 10.0, score_statistics: .make(mean: 10.0, min: 0.0, max: 10.0)))
        lookalike.submission = Submission.make(from: .make(
            grade: "10.0",
            score: 10.0,
            workflow_state: .graded
        ))

        validateLayout(assignment: lookalike, allowedError: 1.0)
    }

    func testLabelsCorrectText() {
        let a = Assignment.make(from: .make(grading_type: .points, points_possible: 10.0, score_statistics: .make(mean: 5.0, min: 2.0, max: 8.0)))
        a.submission = Submission.make(from: .make(
            grade: "6.0",
            score: 6.0,
            workflow_state: .graded
        ))
        view.update(a)
        XCTAssertEqual(view.minLabel.text, "Low: 2.0")
        XCTAssertEqual(view.maxLabel.text, "High: 8.0")
        XCTAssertEqual(view.averageLabel.text, "Mean: 5.0")
    }
}
