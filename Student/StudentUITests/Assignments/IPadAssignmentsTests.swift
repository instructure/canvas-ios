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
import TestsFoundation
@testable import Core

class IPadAssignmentsTest: MiniCanvasUITestCase {
    func assertHas(assignment: APIAssignment) {
        let id = assignment.id.value
        let expectedLabel = "\(assignment.name) \(assignment.due_at == nil ? "No Due Date" : "Due")"
        XCTAssert(AssignmentsList.assignment(id: id).label().hasPrefix(expectedLabel))
    }

    func makeTextSubmission(score: Int? = nil, comments: [APISubmissionComment]? = nil) -> APISubmission {
        APISubmission.make(
            id: 8,
            assignment_id: 2,
            grade: score.map(String.init),
            score: score.map(Double.init),
            submission_type: .online_text_entry,
            workflow_state: score == nil ? .submitted : .graded,
            submission_comments: comments
        )
    }

    func makePointsTextAssignment(submissions: [APISubmission]? = nil) -> APIAssignment {
        return APIAssignment.make(
            id: 2,
            course_id: firstCourse.api.id,
            name: "Points Text Assignment",
            points_possible: 15,
            due_at: nil,
            submission: submissions?.last ?? APISubmission.make(submitted_at: nil, workflow_state: .unsubmitted),
            submissions: submissions,
            grading_type: .points,
            submission_types: [.online_text_entry]
        )
    }

    func testAssignments() {
        XCUIDevice.shared.orientation = .landscapeLeft
        SpringBoard.shared.setupSplitScreenWithSafariOnRight()
        SpringBoard.shared.moveSplit(toFraction: 0.75)

        let now = Date(fromISOString: "2019-11-20T06:00:00Z")!
        let pointsTextAssignment = MiniAssignment(makePointsTextAssignment(), state: mocked)
        let letterGradeSubmission = APISubmission.make(
            grade: "16",
            score: 16,
            submission_type: .online_text_entry,
            submitted_at: now,
            workflow_state: .graded
        )
        let letterGradeTextAssignment = MiniAssignment(.make(
            id: 3,
            course_id: firstCourse.api.id,
            name: "Letter Grade Text Assignment",
            points_possible: 20,
            due_at: now.addDays(1),
            submission: letterGradeSubmission,
            submissions: [letterGradeSubmission],
            grading_type: .letter_grade,
            submission_types: [.online_text_entry]
            ), state: mocked)
        let percentFileAssignment = MiniAssignment(.make(
            id: 4,
            course_id: firstCourse.api.id,
            name: "Percent File Assignment",
            points_possible: 25.0,
            due_at: now.addDays(1),
            grading_type: .percent,
            submission_types: [.online_upload]
            ), state: mocked)
        firstCourse.removeAllAssignments()
        firstCourse.add(assignment: pointsTextAssignment)
        firstCourse.add(assignment: letterGradeTextAssignment)
        firstCourse.add(assignment: percentFileAssignment)

        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.assignments.tap()
        assertHas(assignment: pointsTextAssignment.api)
        assertHas(assignment: letterGradeTextAssignment.api)
        assertHas(assignment: percentFileAssignment.api)

        // Let's submit a text assignment
        XCTAssertEqual(AssignmentDetails.name.label(), "Points Text Assignment")

        XCTAssertFalse(AssignmentDetails.submittedText.isVisible)
        AssignmentDetails.submitAssignmentButton.tap()

        RichContentEditor.webView.typeText("hello!")
        TextSubmission.submitButton.tap()
        XCTAssertEqual(AssignmentDetails.submittedText.label(), "Successfully submitted!")

        // grade the assignment
        pointsTextAssignment.add(submission: makeTextSubmission(score: 13))

        pullToRefresh()
        AssignmentDetails.submittedText.waitToVanish()
        XCTAssertEqual(AssignmentDetails.gradeCircle.waitToExist().label(), "Scored 13 out of 15 points possible")

        AssignmentsList.assignment(id: letterGradeTextAssignment.id).tap()
        XCTAssertEqual(AssignmentDetails.name.label(), "Letter Grade Text Assignment")
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 16 out of 20 points possible")

        AssignmentsList.assignment(id: pointsTextAssignment.id).tap()
        AssignmentDetails.viewSubmissionButton.tap()
        app.find(label: "Comments").tap()

        SubmissionComments.commentTextView.typeText("a comment")
        SubmissionComments.addCommentButton.tap()
        let commentLabel = app.find(idStartingWith: "SubmissionComments.textCell").label()
        XCTAssertTrue(commentLabel.contains("\(mocked.selfUser.name) commented \"a comment\""))
    }
}
