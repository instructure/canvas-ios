//
// Copyright (C) 2017-present Instructure, Inc.
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

import Foundation
@testable import Core
import TestsFoundation

class AssignmentDetailsTests: StudentUITestCase {
    lazy var course: APICourse = {
        let course = APICourse.make()
        mockData(GetCourseRequest(courseID: course.id), value: course)
        return course
    }()

    func mockAssignment(_ assignment: APIAssignment) -> APIAssignment {
        mockData(GetAssignmentRequest(courseID: course.id, assignmentID: assignment.id.value, include: [.submission]), value: assignment)
        return assignment
    }

    override func setUp() {
        super.setUp()
        sleep(1) // only this file seems to need some extra cooldown time.
    }

    override func show(_ route: String) {
        super.show(route)
        sleep(1)
    }

    func testUnsubmittedUpload() {
        mockData(GetCustomColorsRequest(), value: APICustomColors(custom_colors: [
            course.canvasContextID: "#123456",
        ]))
        host.logIn(domain: "canvas.instructure.com", token: "")
        let assignment = mockAssignment(APIAssignment.make(
            description: "A description",
            points_possible: 12.3,
            due_at: DateComponents(calendar: Calendar.current, year: 2035, month: 1, day: 1, hour: 8).date,
            submission_types: [ .online_upload ],
            allowed_extensions: [ "doc", "docx", "pdf" ]
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.allowedExtensions.waitToExist(5)
        XCTAssertEqual(NavBar.title.label, "Assignment Details")
        XCTAssertEqual(NavBar.subtitle.label, course.name!)
        XCTAssertEqual(navBarColorHex(), "#123456")

        XCTAssertEqual(AssignmentDetails.name.label, assignment.name)
        XCTAssertEqual(AssignmentDetails.points.label, "12.3 pts")
        XCTAssertEqual(AssignmentDetails.status.label, "Not Submitted")
        XCTAssertEqual(AssignmentDetails.due.label, "Jan 1, 2035 at 8:00 AM")
        XCTAssertEqual(AssignmentDetails.submissionTypes.label, "File Upload")
        XCTAssertEqual(AssignmentDetails.allowedExtensions.label, "doc, docx, or pdf")
        XCTAssertFalse(AssignmentDetails.submittedText.isVisible)
        XCTAssertFalse(AssignmentDetails.gradeCell.isVisible)
        XCTAssertEqual(AssignmentDetails.submitAssignmentButton.label, "Submit Assignment")

        let description = app.webViews.staticTexts.firstMatch.label
        XCTAssertEqual(description, assignment.description)
    }

    func testUnsubmittedDiscussion() {
        let assignment = mockAssignment(APIAssignment.make(
            name: "Discuss this",
            description: "Say it like you mean it",
            points_possible: 15.1,
            due_at: DateComponents(calendar: Calendar.current, year: 2035, month: 1, day: 1, hour: 8).date,
            submission_types: [ .discussion_topic ],
            discussion_topic: APIDiscussionTopic.make(
                message: "Say something I'm giving up on you."
            )
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.submissionTypes.waitToExist(5)
        XCTAssertEqual(AssignmentDetails.name.label, assignment.name)
        XCTAssertEqual(AssignmentDetails.points.label, "15.1 pts")
        XCTAssertEqual(AssignmentDetails.status.label, "Not Submitted")
        XCTAssertEqual(AssignmentDetails.due.label, "Jan 1, 2035 at 8:00 AM")
        XCTAssertEqual(AssignmentDetails.submissionTypes.label, "Discussion Comment")
        XCTAssertFalse(AssignmentDetails.allowedExtensions.isVisible)
        XCTAssertFalse(AssignmentDetails.submittedText.isVisible)
        XCTAssertFalse(AssignmentDetails.gradeCell.isVisible)
        XCTAssertEqual(AssignmentDetails.submitAssignmentButton.label, "View Discussion")

        let authorAvatar = app.webViews.staticTexts.element(boundBy: 0).label
        let authorName = app.webViews.staticTexts.element(boundBy: 1).label
        let message = app.webViews.staticTexts.element(boundBy: 2).label
        XCTAssertEqual(authorAvatar, "B")
        XCTAssertEqual(authorName, assignment.discussion_topic?.author.display_name)
        XCTAssertEqual(message, assignment.discussion_topic?.message)
    }

    func testSubmittedDiscussion() {
        let assignment = mockAssignment(APIAssignment.make(
            submission: APISubmission.make(
                discussion_entries: [ APIDiscussionEntry.make(
                    message: "My discussion entry"
                ), ]
            ),
            submission_types: [ .discussion_topic ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.name.label, assignment.name)
        XCTAssertTrue(AssignmentDetails.submittedText.isVisible)
        XCTAssertTrue(AssignmentDetails.gradeCell.isVisible)
        XCTAssertEqual(AssignmentDetails.submitAssignmentButton.label, "View Discussion")
    }

    func testResubmitAssignmentButton() {
        let assignment = mockAssignment(APIAssignment.make(
            submission: APISubmission.make(),
            submission_types: [ .online_upload ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.submitAssignmentButton.label, "Resubmit Assignment")
    }

    func testSubmitAssignmentButton() {
        let assignment = mockAssignment(APIAssignment.make(
            submission_types: [ .online_upload ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.submitAssignmentButton.label, "Submit Assignment")
    }

    func testNoSubmitAssignmentButtonShows() {
        let assignment = mockAssignment(APIAssignment.make(
            submission_types: [ .none ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertFalse(AssignmentDetails.submitAssignmentButton.isVisible)
    }

    func testNoSubmitAssignmentButtonShowsWhenLockAtLessThanNow() {
        let assignment = mockAssignment(APIAssignment.make(
            lock_at: Date().addDays(-1)
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertFalse(AssignmentDetails.submitAssignmentButton.isVisible)
    }

    func testNoSubmitAssignmentButtonShowsWhenUnLockAtGreaterThanNow() {
        let assignment = mockAssignment(APIAssignment.make(
            unlock_at: Date().addDays(1)
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertFalse(AssignmentDetails.submitAssignmentButton.isVisible)
    }

    func testNoSubmitAssignmentButtonShowsUserNotStudentEnrollment() {
        mockData(GetCourseRequest(courseID: course.id), value: APICourse.make(enrollments: []))
        let assignment = mockAssignment(APIAssignment.make(
            submission_types: [ .online_upload ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertFalse(AssignmentDetails.submitAssignmentButton.isVisible)
    }

    func testTappingSubmitButtonShowsFileUploadOption() {
        let assignment = mockAssignment(APIAssignment.make(
            submission_types: [ .online_upload, .online_url ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.submitAssignmentButton.waitToExist(5)
        AssignmentDetails.submitAssignmentButton.tap()
        XCTAssertTrue(app.find(label: "File Upload").isVisible)
    }

    func testCancelSubmitAction() {
        let assignment = mockAssignment(APIAssignment.make(
            submission_types: [ .online_upload, .online_url ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.submitAssignmentButton.tap()
        app.find(label: "Cancel").tap()
        XCTAssertEqual(app.alerts.count, 0)
    }

    func testGradeCellShowsSubmittedTextWhenNotGraded() {
        let assignment = mockAssignment(APIAssignment.make(
            submission: APISubmission.make()
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertTrue(AssignmentDetails.submittedText.isVisible)
        XCTAssertEqual(AssignmentDetails.submittedText.label, "Successfully submitted!")
    }

    func testGradeCellShowsDialWhenGraded() {
        let assignment = mockAssignment(APIAssignment.make(
            points_possible: 100,
            submission: APISubmission.make(
                grade: "90",
                score: 90
            )
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.gradeCircle.label, "Scored 90 out of 100 points possible")
    }

    func testDisplayGradeAs() {
        let assignment = mockAssignment(APIAssignment.make(
            points_possible: 10,
            submission: APISubmission.make(
                grade: "80%",
                score: 8
            ),
            grading_type: .percent
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.gradeCircle.label, "Scored 8 out of 10 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label, "80%")
    }

    func testGradeCellShowsLatePenalty() {
        let assignment = mockAssignment(APIAssignment.make(
            points_possible: 100,
            due_at: Date(timeIntervalSinceNow: -10000), // less than 1 day should deduct 5 points
            submission: APISubmission.make(
                grade: "85",
                score: 85,
                late: true,
                late_policy_status: .late,
                points_deducted: 5
            )
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        XCTAssertEqual(AssignmentDetails.gradeLatePenalty.label, "Late penalty (-5 pts)")
    }

    func testViewSubmissionButtonWorksWithNoSubmission() {
        let assignment = mockAssignment(APIAssignment.make(
            points_possible: 10
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.viewSubmissionButton.waitToExist(5)
        AssignmentDetails.viewSubmissionButton.tap()
        XCTAssertTrue(SubmissionDetails.emptySubmitButton.exists)
    }

    func testSubmissionButtonNavigatesToSubmission() {
        let assignment = mockAssignment(APIAssignment.make(
            points_possible: 10,
            submission: APISubmission.make()
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.viewSubmissionButton.tap()
        XCTAssertTrue(SubmissionDetails.attemptPickerToggle.isVisible)
    }

    func testSubmitUrlSubmission() {
        let assignment = mockAssignment(APIAssignment.make(
            submission_types: [ .online_url ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.submitAssignmentButton.waitToExist()
        XCTAssertEqual(AssignmentDetails.submitAssignmentButton.label, "Submit Assignment")
        AssignmentDetails.submitAssignmentButton.tap()
        AssignmentDetails.submitAssignmentButton.waitToVanish()
    }
}
