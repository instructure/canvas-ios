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
@testable import CoreUITests
@testable import Core

class IPadAssignmentsTest: CoreUITestCase {
    func assertHas(assignment: APIAssignment) {
        let id = assignment.id.value
        XCTAssertEqual(AssignmentsList.assignmentName(id: id).label(), assignment.name)
        if assignment.due_at != nil {
            XCTAssertTrue(AssignmentsList.assignmentDue(id: id).label().hasPrefix("Due"))
        } else {
            XCTAssertTrue(AssignmentsList.assignmentDue(id: id).label().contains("No Due Date"))
        }
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
            name: "Points Text Assignment",
            points_possible: 15,
            due_at: nil,
            submission: submissions?.last ?? APISubmission.make(submitted_at: nil, workflow_state: .unsubmitted),
            submissions: submissions,
            grading_type: .points,
            submission_types: [.online_text_entry]
        )
    }

    func xtestAssignments() {
        XCUIDevice.shared.orientation = .landscapeLeft
        SpringBoard.shared.setupSplitScreenWithSafariOnRight()
        SpringBoard.shared.moveSplit(toFraction: 0.75)

        let now = Date(fromISOString: "2019-11-20T06:00:00Z")!
        mockNow(now)
        mockEncodableRequest("users/self/groups?include[]=users", value: [String]())
        mockEncodableRequest("conversations?include[]=participant_avatars&per_page=50", value: [String]())
        mockEncodableRequest("courses?enrollment_state=active&include[]=course_image&include[]=current_grading_period_scores&include[]=favorites&include[]=observed_users&include[]=section" +
            "s&include[]=term&include[]=total_scores&per_page=10", value: [String]())

        let course = mock(course: APICourse.make())
        var pointsTextAssignment = mock(assignment: makePointsTextAssignment())
        let letterGradeSubmission = APISubmission.make(
            grade: "16",
            score: 16,
            submission_type: .online_text_entry,
            submitted_at: now,
            workflow_state: .graded
        )
        let letterGradeTextAssignment = mock(assignment: APIAssignment.make(
            id: 3,
            name: "Letter Grade Text Assignment",
            points_possible: 20,
            due_at: now.addDays(1),
            submission: letterGradeSubmission,
            submissions: [letterGradeSubmission],
            grading_type: .letter_grade,
            submission_types: [.online_text_entry]
        ))
        let percentFileAssignment = mock(assignment: APIAssignment.make(
            id: 4,
            name: "Percent File Assignment",
            points_possible: 25.0,
            due_at: now.addDays(1),
            grading_type: .percent,
            submission_types: [.online_upload]
        ))

        mockBaseRequests()
        mockData(GetTabsRequest(context: .course(course.id.value), perPage: nil), value: [
            APITab.make(
                id: ID("assignments"),
                html_url: URL(string: "/courses/\(course.id)/assignments")!,
                label: "Assignments"
            ),
        ])
        let group = APIAssignmentListGroup.make(
            id: course.id,
            name: "a group",
            assignments: [pointsTextAssignment, letterGradeTextAssignment, percentFileAssignment].map {
                APIAssignmentListAssignment(apiAssignment: $0)
            }
        )
        mockData(AssignmentListRequestable(courseID: course.id.value, filter: .allGradingPeriods),
                 value: APIAssignmentListResponse.make(groups: [group]))
        logIn()
        Dashboard.courseCard(id: course.id.value).tap()
        CourseNavigation.assignments.tap()
        assertHas(assignment: pointsTextAssignment)
        assertHas(assignment: letterGradeTextAssignment)
        assertHas(assignment: percentFileAssignment)

        // Let's submit a text assignment
        XCTAssertEqual(AssignmentDetails.name.label(), "Points Text Assignment")

        XCTAssertFalse(AssignmentDetails.submittedText.isVisible)
        AssignmentDetails.submitAssignmentButton.tap()

        func describeQuery(_ query: XCUIElementQuery?) {
            guard let query = query else {
                print("nil")
                return
            }
            describeQuery(query.value(forKey: "inputQuery") as? XCUIElementQuery)
            print("-> \(query.value(forKey: "queryDescription")!)")
        }

        RichContentEditor.webView.typeText("hello!")
        mockData(CreateSubmissionRequest(context: .course(course.id.value), assignmentID: pointsTextAssignment.id.value, body: nil), value: makeTextSubmission())
        TextSubmission.submitButton.tap()
        XCTAssertEqual(AssignmentDetails.submittedText.label(), "Successfully submitted!")

        // grade the assignment
        var pointsTextSubmission = makeTextSubmission(score: 13)
        pointsTextAssignment = mock(assignment: makePointsTextAssignment(submissions: [pointsTextSubmission]))
        pullToRefresh()
        AssignmentDetails.submittedText.waitToVanish()
        XCTAssertEqual(AssignmentDetails.gradeCircle.waitToExist().label(), "Scored 13 out of 15 points possible")

        AssignmentsList.assignment(id: letterGradeTextAssignment.id.value).tap()
        XCTAssertEqual(AssignmentDetails.name.label(), "Letter Grade Text Assignment")
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 16 out of 20 points possible")

        AssignmentsList.assignment(id: pointsTextAssignment.id.value).tap()
        AssignmentDetails.viewSubmissionButton.tap()
        app.find(label: "Comments").tap()

        pointsTextSubmission = makeTextSubmission(score: 13, comments: [.make(comment: "a comment")])
        mockData(PutSubmissionGradeRequest(courseID: course.id.value, assignmentID: pointsTextAssignment.id.value, userID: "1", body: nil),
                 value: pointsTextSubmission)

        SubmissionComments.commentTextView.typeText("a comment")
        SubmissionComments.addCommentButton.tap()
        XCTAssertTrue(SubmissionComments.textCell(commentID: "1").label().contains("Steve commented \"a comment\""))
    }
}
