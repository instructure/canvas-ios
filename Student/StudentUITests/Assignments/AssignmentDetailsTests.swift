//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

import Foundation
@testable import Core
@testable import CoreUITests
import TestsFoundation
import XCTest

class AssignmentDetailsTests: CoreUITestCase {
    lazy var course = mock(course: .make())

    func testUnsubmittedUpload() {
        // FLAKY: color cache doesn't always get updated
        mockBaseRequests()
        mockData(GetCustomColorsRequest(), value: APICustomColors(custom_colors: [
            Context(.course, id: course.id.value).canvasContextID: "#123456",
        ]))
        let assignment = mock(assignment: .make(
            description: "A description",
            points_possible: 12.3,
            due_at: DateComponents(calendar: Calendar.current, year: 2035, month: 1, day: 1, hour: 8).date,
            submission: .make(submitted_at: nil, workflow_state: .unsubmitted),
            submission_types: [ .online_upload ],
            allowed_extensions: [ "doc", "docx", "pdf" ]
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.allowedExtensions.waitToExist()
        XCTAssertEqual(NavBar.title.label(), "Assignment Details")
        XCTAssertEqual(NavBar.subtitle.label(), course.name!)
        XCTAssertEqual(navBarColorHex(), "#123456")

        XCTAssertEqual(AssignmentDetails.name.label(), assignment.name)
        XCTAssertEqual(AssignmentDetails.points.label(), "12.3 pts")
        XCTAssertEqual(AssignmentDetails.status.label(), "Not Submitted")
        XCTAssertEqual(AssignmentDetails.due.label(), "Jan 1, 2035 at 8:00 AM")
        XCTAssertEqual(AssignmentDetails.submissionTypes.label(), "File Upload")
        XCTAssertEqual(AssignmentDetails.allowedExtensions.label(), "doc, docx, or pdf")
        XCTAssertFalse(AssignmentDetails.submittedText.isVisible)
        XCTAssertFalse(AssignmentDetails.gradeCell.isVisible)
        XCTAssertEqual(AssignmentDetails.submitAssignmentButton.label(), "Submit Assignment")

        let description = app.webViews.staticTexts.firstMatch.label
        XCTAssertEqual(description, assignment.description)
    }

    func testUnsubmittedDiscussion() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            name: "Discuss this",
            description: "Say it like you mean it",
            points_possible: 15.1,
            due_at: DateComponents(calendar: Calendar.current, year: 2035, month: 1, day: 1, hour: 8).date,
            submission: .make(submitted_at: nil, workflow_state: .unsubmitted),
            submission_types: [ .discussion_topic ],
            discussion_topic: APIDiscussionTopic.make(
                message: "Say something I'm giving up on you."
            )
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.submissionTypes.waitToExist()
        XCTAssertEqual(AssignmentDetails.name.label(), assignment.name)
        XCTAssertEqual(AssignmentDetails.points.label(), "15.1 pts")
        XCTAssertEqual(AssignmentDetails.status.label(), "Not Submitted")
        XCTAssertEqual(AssignmentDetails.due.label(), "Jan 1, 2035 at 8:00 AM")
        XCTAssertEqual(AssignmentDetails.submissionTypes.label(), "Discussion Comment")
        XCTAssertFalse(AssignmentDetails.allowedExtensions.isVisible)
        XCTAssertFalse(AssignmentDetails.submittedText.isVisible)
        XCTAssertFalse(AssignmentDetails.gradeCell.isVisible)
        XCTAssertEqual(AssignmentDetails.submitAssignmentButton.label(), "View Discussion")

        let authorName = app.webViews.links.element(boundBy: 0).label
        let message = app.webViews.staticTexts.element(boundBy: 0).label
        XCTAssertEqual(authorName, assignment.discussion_topic?.author.display_name)
        XCTAssertEqual(message, assignment.discussion_topic?.message)
    }

    func testSubmittedDiscussion() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            submission: APISubmission.make(
                submission_type: .discussion_topic,
                discussion_entries: [ APIDiscussionEntry.make(
                    message: "My discussion entry"
                ), ]
            ),
            submission_types: [ .discussion_topic ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.name.label(), assignment.name)
        XCTAssertTrue(AssignmentDetails.submittedText.isVisible)
        XCTAssertFalse(AssignmentDetails.gradeCell.isVisible)
        XCTAssertEqual(AssignmentDetails.submitAssignmentButton.label(), "View Discussion")
    }

    func testResubmitAssignmentButton() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            submission: APISubmission.make(),
            submission_types: [ .online_upload ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.submitAssignmentButton.label(), "Resubmit Assignment")
    }

    func testSubmitAssignmentButton() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            submission_types: [ .online_upload ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.submitAssignmentButton.label(), "Submit Assignment")
    }

    func testNoSubmitAssignmentButtonShows() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            submission_types: [ .none ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.name.label(), assignment.name)
        XCTAssertFalse(AssignmentDetails.submitAssignmentButton.isVisible)
    }

    func testNoSubmitAssignmentButtonShowsForNotGraded() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            submission_types: [ .not_graded ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.name.label(), assignment.name)
        XCTAssertFalse(AssignmentDetails.submitAssignmentButton.isVisible)
    }

    func testNoSubmitAssignmentButtonShowsWhenExcused() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            submission: .make(excused: true),
            submission_types: [.online_text_entry]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.name.label(), assignment.name)
        XCTAssertFalse(AssignmentDetails.submitAssignmentButton.isVisible)
    }

    func testNoLockSection() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            submission_types: [ .online_upload ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.submitAssignmentButton.label(), "Submit Assignment")
        XCTAssertFalse(AssignmentDetails.lockIcon.isVisible)
        XCTAssertFalse(AssignmentDetails.lockSection.isVisible)
    }

    func testNoSubmitAssignmentButtonShowsWhenLockAtLessThanNow() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            submission_types: [ .online_upload ],
            allowed_extensions: ["png"],
            lock_at: Date().addDays(-1),
            locked_for_user: true,
            lock_explanation: "this is locked"
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertTrue(AssignmentDetails.lockSection.waitToExist().isVisible)
        XCTAssertTrue(AssignmentDetails.due.waitToExist().isVisible)
        XCTAssertTrue(AssignmentDetails.submissionTypes.waitToExist().isVisible)
        XCTAssertTrue(AssignmentDetails.viewSubmissionButton.waitToExist().isVisible)
        XCTAssertFalse(AssignmentDetails.submitAssignmentButton.isVisible)
        XCTAssertFalse(AssignmentDetails.lockIcon.isVisible)
    }

    func testNoSubmitAssignmentButtonShowsWhenUnLockAtGreaterThanNow() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            submission_types: [ .online_upload ],
            allowed_extensions: ["png"],
            unlock_at: Date().addDays(1),
            locked_for_user: true,
            lock_explanation: "this is locked"
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertTrue(AssignmentDetails.lockIcon.waitToExist().isVisible)
        XCTAssertTrue(AssignmentDetails.lockSection.waitToExist().isVisible)
        XCTAssertFalse(AssignmentDetails.due.isVisible)
        XCTAssertFalse(AssignmentDetails.gradeCell.isVisible)
        XCTAssertFalse(AssignmentDetails.submissionTypes.isVisible)
        XCTAssertFalse(AssignmentDetails.viewSubmissionButton.isVisible)
        XCTAssertFalse(AssignmentDetails.submitAssignmentButton.isVisible)
    }

    func testNoSubmitAssignmentButtonShowsUserNotStudentEnrollment() {
        mockBaseRequests()
        mockData(GetCourseRequest(courseID: course.id.value), value: APICourse.make(enrollments: []))
        let assignment = mock(assignment: .make(
            submission_types: [ .online_upload ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.name.label(), assignment.name)
        XCTAssertFalse(AssignmentDetails.submitAssignmentButton.isVisible)
    }

    func testTappingSubmitButtonShowsFileUploadOption() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            submission_types: [ .online_upload, .online_url ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.submitAssignmentButton.waitToExist(5)
        AssignmentDetails.submitAssignmentButton.tap()
        XCTAssertTrue(app.find(label: "File Upload").isVisible)
    }

    func testCancelSubmitAction() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            submission_types: [ .online_upload, .online_url ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.submitAssignmentButton.tap()
        app.find(label: "Cancel").tap()
        XCTAssertEqual(app.alerts.count, 0)
    }

    func testGradeCellShowsSubmittedTextWhenNotGraded() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            submission: APISubmission.make(submission_type: .online_upload, workflow_state: .pending_review)
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertTrue(AssignmentDetails.submittedText.waitToExist().isVisible)
        XCTAssertEqual(AssignmentDetails.submittedText.label(), "Successfully submitted!")
    }

    func testGradeCellShowsDialWhenGraded() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            points_possible: 100,
            submission: APISubmission.make(
                grade: "90",
                score: 90,
                workflow_state: .graded
            )
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 90 out of 100 points possible")
    }

    func testDisplayGradeAs() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            points_possible: 10,
            submission: APISubmission.make(
                grade: "80%",
                score: 8,
                workflow_state: .graded
            ),
            grading_type: .percent
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 8 out of 10 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "80%")
    }

    func testGradeCellShowsLatePenalty() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            points_possible: 100,
            due_at: Date(timeIntervalSinceNow: -10000), // less than 1 day should deduct 5 points
            submission: APISubmission.make(
                grade: "85",
                score: 85,
                late: true,
                workflow_state: .graded,
                late_policy_status: .late,
                points_deducted: 5
            )
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.gradeLatePenalty.label(), "Late penalty (-5 pts)")
    }

    func testGradeCellShowsExcused() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            points_possible: 100,
            submission: .make(excused: true)
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertTrue(AssignmentDetails.gradeCell.waitToExist().isVisible)
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "Excused")
        XCTAssertEqual(AssignmentDetails.gradeCircleOutOf.label(), "Out of 100 pts")
    }

    func testViewSubmissionButtonWorksWithNoSubmission() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            points_possible: 10
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.viewSubmissionButton.waitToExist(5)
        AssignmentDetails.viewSubmissionButton.tap()
        XCTAssertTrue(SubmissionDetails.emptySubmitButton.exists)
    }

    func testSubmissionButtonNavigatesToSubmission() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            points_possible: 10,
            submission: APISubmission.make(submission_type: .online_upload, workflow_state: .submitted)
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.viewSubmissionButton.tap()
        XCTAssertTrue(SubmissionDetails.attemptPickerToggle.isVisible)
    }

    func testGradeCellNavigatesToSubmission() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            points_possible: 10,
            submission: APISubmission.make(
                grade: "80%",
                score: 8,
                workflow_state: .graded
            ),
            grading_type: .percent
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.gradeCell.tap()
        XCTAssertTrue(SubmissionDetails.attemptPickerToggle.isVisible)
    }

    func testSubmitUrlSubmission() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            submission_types: [ .online_url ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.submitAssignmentButton.label(), "Submit Assignment")
        AssignmentDetails.submitAssignmentButton.tap()
        URLSubmission.submit.waitToExist()
    }
}
