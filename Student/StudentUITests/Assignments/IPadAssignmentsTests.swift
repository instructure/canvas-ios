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
        let expectedLabel = "\(assignment.name), \(assignment.due_at == nil ? "No Due Date, 1 NEEDS GRADING" : "Due")"
        XCTAssert(AssignmentsList.assignment(id: id).waitToExist().label().hasPrefix(expectedLabel))
    }

    func makeTextSubmission(score: Int? = nil, comments: [APISubmissionComment]? = nil) -> APISubmission {
        APISubmission.make(
            assignment_id: "2",
            grade: score.map(String.init),
            id: "8",
            score: score.map(Double.init),
            submission_comments: comments,
            submission_type: .online_text_entry,
            workflow_state: score == nil ? .submitted : .graded
        )
    }

    func makePointsTextAssignment(submissions: [APISubmission]? = nil) -> APIAssignment {
        return APIAssignment.make(
            course_id: firstCourse.api.id,
            due_at: nil,
            grading_type: .points,
            id: 2,
            name: "Points Text Assignment",
            points_possible: 15,
            submission: submissions?.last ?? APISubmission.make(submitted_at: nil, workflow_state: .unsubmitted),
            submissions: submissions,
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
            course_id: firstCourse.api.id,
            due_at: now.addDays(1),
            grading_type: .letter_grade,
            id: 3,
            name: "Letter Grade Text Assignment",
            points_possible: 20,
            submission: letterGradeSubmission,
            submissions: [letterGradeSubmission],
            submission_types: [.online_text_entry]
        ), state: mocked)
        let percentFileAssignment = MiniAssignment(.make(
            course_id: firstCourse.api.id,
            due_at: now.addDays(1),
            grading_type: .percent,
            id: 4,
            name: "Percent File Assignment",
            points_possible: 25.0,
            submission_types: [.online_upload]
        ), state: mocked)
        firstCourse.removeAllAssignments()
        firstCourse.add(assignment: pointsTextAssignment)
        firstCourse.add(assignment: letterGradeTextAssignment)
        firstCourse.add(assignment: percentFileAssignment)

        TabBar.inboxTab.tap()
        TabBar.dashboardTab.tap()
        Dashboard.courseCard(id: firstCourse.id).waitToExist().tap()
        CourseNavigation.assignments.tap()
        assertHas(assignment: pointsTextAssignment.api)
        assertHas(assignment: letterGradeTextAssignment.api)
        assertHas(assignment: percentFileAssignment.api)

        // Let's submit a text assignment
        AssignmentsList.assignment(id: pointsTextAssignment.id).tap()
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

        // when the assignment is opened in the detail view it disappears from the list,
        // so we refresh it to get it back... mocking issue?
        pullToRefresh(x: 0.1)
        AssignmentsList.assignment(id: pointsTextAssignment.id).tap()
        AssignmentDetails.viewSubmissionButton.tap()
        app.find(label: "Comments").tap()

        SubmissionComments.commentTextView.typeText("a comment")
        SubmissionComments.addCommentButton.tap()
        let commentLabel = app.find(idStartingWith: "SubmissionComments.textCell").label()
        XCTAssertTrue(commentLabel.contains("\(mocked.selfUser.name) commented \"a comment\""))
    }
}
