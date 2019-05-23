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

class AssignmentDetailsPageTest: StudentTest {
    let page = AssignmentDetailsPage.self
    let filePicker = FilePickerPage.self

    lazy var course: APICourse = {
        let course = APICourse.make()
        mockData(GetCourseRequest(courseID: course.id), value: course)
        return course
    }()

    func mockAssignment(_ assignment: APIAssignment) -> APIAssignment {
        mockData(GetAssignmentRequest(courseID: course.id, assignmentID: assignment.id.value, include: [.submission]), value: assignment)
        return assignment
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
        page.waitToExist(.allowedExtensions, timeout: 5)
        NavBar.assertText(.title, equals: "Assignment Details")
        NavBar.assertText(.subtitle, equals: course.name!)
        XCTAssertEqual(navBarColorHex(), "#123456")

        page.assertText(.name, equals: assignment.name)
        page.assertText(.points, equals: "12.3 pts")
        page.assertText(.status, equals: "Not Submitted")
        page.assertText(.due, equals: "Jan 1, 2035 at 8:00 AM")
        page.assertText(.submissionTypes, equals: "File Upload")
        page.assertText(.allowedExtensions, equals: "doc, docx, or pdf")
        page.assertHidden(.submittedText)
        page.assertHidden(.gradeCell)
        page.assertText(.submitAssignmentButton, equals: "Submit Assignment")

        let description = xcuiApp?.webViews.staticTexts.firstMatch.label
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
        page.waitToExist(.submissionTypes, timeout: 5)
        page.assertText(.name, equals: assignment.name)
        page.assertText(.points, equals: "15.1 pts")
        page.assertText(.status, equals: "Not Submitted")
        page.assertText(.due, equals: "Jan 1, 2035 at 8:00 AM")
        page.assertText(.submissionTypes, equals: "Discussion Comment")
        page.assertHidden(.allowedExtensions)
        page.assertHidden(.submittedText)
        page.assertHidden(.gradeCell)
        page.assertText(.submitAssignmentButton, equals: "View Discussion")

        let authorAvatar = xcuiApp?.webViews.staticTexts.element(boundBy: 0).label
        let authorName = xcuiApp?.webViews.staticTexts.element(boundBy: 1).label
        let message = xcuiApp?.webViews.staticTexts.element(boundBy: 2).label
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
        page.assertText(.name, equals: assignment.name)
        page.assertVisible(.submittedText)
        page.assertVisible(.gradeCell)
        page.assertText(.submitAssignmentButton, equals: "View Discussion")
    }

    func testResubmitAssignmentButton() {
        let assignment = mockAssignment(APIAssignment.make(
            submission: APISubmission.make(),
            submission_types: [ .online_upload ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        page.assertText(.submitAssignmentButton, equals: "Resubmit Assignment")
    }

    func testSubmitAssignmentButton() {
        let assignment = mockAssignment(APIAssignment.make(
            submission_types: [ .online_upload ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        page.assertText(.submitAssignmentButton, equals: "Submit Assignment")
    }

    func testNoSubmitAssignmentButtonShows() {
        let assignment = mockAssignment(APIAssignment.make(
            submission_types: [ .none ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        page.assertHidden(.submitAssignmentButton)
    }

    func testNoSubmitAssignmentButtonShowsWhenLockAtLessThanNow() {
        let assignment = mockAssignment(APIAssignment.make(
            lock_at: Date().addDays(-1)
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        page.assertHidden(.submitAssignmentButton)
    }

    func testNoSubmitAssignmentButtonShowsWhenUnLockAtGreaterThanNow() {
        let assignment = mockAssignment(APIAssignment.make(
            unlock_at: Date().addDays(1)
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        page.assertHidden(.submitAssignmentButton)
    }

    func testNoSubmitAssignmentButtonShowsUserNotStudentEnrollment() {
        mockData(GetCourseRequest(courseID: course.id), value: APICourse.make(enrollments: []))
        let assignment = mockAssignment(APIAssignment.make(
            submission_types: [ .online_upload ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        page.assertHidden(.submitAssignmentButton)
    }

    func testTappingSubmitButtonShowsFileUploadOption() {
        let assignment = mockAssignment(APIAssignment.make(
            submission_types: [ .online_upload, .online_url ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        page.waitToExist(.submitAssignmentButton, timeout: 5)
        page.tap(.submitAssignmentButton)
        page.assertAlertActionExists("File Upload")
    }

    func testCancelSubmitAction() {
        let assignment = mockAssignment(APIAssignment.make(
            submission_types: [ .online_upload, .online_url ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        page.tap(.submitAssignmentButton)
        page.tapAlertAction("Cancel")
        page.assertAlertHidden()
    }

    func testGradeCellShowsSubmittedTextWhenNotGraded() {
        let assignment = mockAssignment(APIAssignment.make(
            submission: APISubmission.make()
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        page.assertVisible(.submittedText)
        page.assertText(.submittedText, equals: "Successfully submitted!")
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
        page.select(.gradeCircle).assertText(equals: "Scored 90 out of 100 points possible")
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
        page.select(.gradeCircle).assertText(equals: "Scored 8 out of 10 points possible")
        page.select(.gradeDisplayGrade).assertText(equals: "80%")
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
        page.select(.gradeLatePenalty).assertText(equals: "Late penalty (-5 pts)")
    }

    func testViewSubmissionButtonWorksWithNoSubmission() {
        let assignment = mockAssignment(APIAssignment.make(
            points_possible: 10
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        page.waitToExist(.viewSubmissionButton, timeout: 5)
        page.tap(.viewSubmissionButton)
        XCTAssertTrue(SubmissionDetails.emptySubmitButton.exists)
    }

    func testSubmissionButtonNavigatesToSubmission() {
        let assignment = mockAssignment(APIAssignment.make(
            points_possible: 10,
            submission: APISubmission.make()
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        page.tap(.viewSubmissionButton)
        XCTAssertTrue(SubmissionDetails.attemptPickerToggle.isVisible)
    }

    func testSubmitUrlSubmission() {
        let assignment = mockAssignment(APIAssignment.make(
            submission_types: [ .online_url ]
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        page.assertText(.submitAssignmentButton, equals: "Submit Assignment")
        page.tap(.submitAssignmentButton)
        page.assertHidden(.submitAssignmentButton)
    }
}
