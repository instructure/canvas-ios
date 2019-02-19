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
    let submissionDetailsPage = SubmissionDetailsPage.self

    lazy var course: APICourse = {
        return seedClient.createCourse()
    }()
    lazy var teacher: AuthUser = {
        return createTeacher(in: course)
    }()
    lazy var student: AuthUser = {
        return createStudent(in: course)
    }()

    func testUnsubmittedUpload() {
        seedClient.updateCustomColor(user: student, context: ContextModel(.course, id: course.id), hexcode: "123456")
        let assignment = seedClient.createAssignment(
            for: course,
            description: "A description",
            pointsPossible: 12.3,
            dueAt: DateComponents(calendar: Calendar.current, year: 2035, month: 1, day: 1, hour: 8).date,
            submissionTypes: [.online_upload],
            allowedExtensions: ["doc", "docx", "pdf"]
        )
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: student)

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

        let description = app?.webViews.staticTexts.firstMatch.label
        XCTAssertEqual(description, assignment.description)
    }

    func testUnsubmittedDiscussion() {
        let discussion = seedClient.createGradedDiscussionTopic(
            for: course,
            title: "Discuss this",
            message: "Say it like you mean it",
            pointsPossible: 15.1,
            dueAt: DateComponents(calendar: Calendar.current, year: 2035, month: 1, day: 1, hour: 8).date
        )

        XCTAssertNotNil(discussion.assignment_id)
        launch("/courses/\(course.id)/assignments/\(discussion.assignment_id!)", as: student)

        page.assertText(.name, equals: discussion.title!)
        page.assertText(.points, equals: "15.1 pts")
        page.assertText(.status, equals: "Not Submitted")
        page.assertText(.due, equals: "Jan 1, 2035 at 8:00 AM")
        page.assertText(.submissionTypes, equals: "Discussion Comment")
        page.assertHidden(.allowedExtensions)
        page.assertHidden(.submittedText)
        page.assertHidden(.gradeCell)
        page.assertText(.submitAssignmentButton, equals: "Submit Assignment")

        let description = app?.webViews.staticTexts.firstMatch.label
        XCTAssertEqual(description, discussion.message!)
    }

    func xtestSubmittedDiscussion() {
        let discussion = seedClient.createGradedDiscussionTopic(for: course)
        seedClient.createDiscussionEntry(discussion, context: ContextModel(.course, id: course.id), message: "My discussion entry", as: student)

        XCTAssertNotNil(discussion.assignment_id)
        launch("/courses/\(course.id)/assignments/\(discussion.assignment_id!)", as: student)

        page.assertText(.name, equals: discussion.title!)
        page.assertVisible(.submittedText)
        page.assertVisible(.gradeCell)
        page.assertText(.submitAssignmentButton, equals: "Resubmit Assignment")

        let description = app?.webViews.staticTexts.firstMatch.label
        XCTAssertEqual(description, discussion.message!)
    }

    func testResubmitAssignmentButton() {
        let assignment = seedClient.createAssignment(for: course)
        seedClient.submit(assignment: assignment, context: ContextModel(.course, id: course.id), as: student)
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: student)

        page.assertText(.submitAssignmentButton, equals: "Resubmit Assignment")
    }

    func testSubmitAssignmentButton() {
        let assignment = seedClient.createAssignment(for: course, submissionTypes: [.online_upload])
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: student)
        page.assertText(.submitAssignmentButton, equals: "Submit Assignment")
    }

    func testNoSubmitAssignmentButtonShows() {
        let assignment = seedClient.createAssignment(for: course, submissionTypes: [.none])
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: student)
        page.assertHidden(.submitAssignmentButton)
    }

    func testNoSubmitAssignmentButtonShowsWhenLockAtLessThanNow() {
        let assignment = seedClient.createAssignment(for: course, lockAt: Date().addDays(-1))
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: student)
        page.assertHidden(.submitAssignmentButton)
    }

    func testNoSubmitAssignmentButtonShowsWhenUnLockAtGreaterThanNow() {
        let assignment = seedClient.createAssignment(for: course, unlockAt: Date().addDays(1))
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: student)
        page.assertHidden(.submitAssignmentButton)
    }

    func testNoSubmitAssignmentButtonShowsUserNotStudentEnrollment() {
        let assignment = seedClient.createAssignment(for: course, submissionTypes: [.online_upload])
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: teacher)
        page.assertHidden(.submitAssignmentButton)
    }

    func testTappingSubmitButtonShowsFileUploadOption() {
        let assignment = seedClient.createAssignment(for: course, submissionTypes: [.online_upload, .online_url])
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: student)
        page.tap(.submitAssignmentButton)
        page.assertAlertActionExists("File Upload")
    }

    func testCancelSubmitAction() {
        let assignment = seedClient.createAssignment(for: course, submissionTypes: [.online_upload, .online_url])
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: student)
        page.tap(.submitAssignmentButton)
        page.tapAlertAction("Cancel")
        page.assertAlertHidden()
    }

    func testGradeCellShowsSubmittedTextWhenNotGraded() {
        let assignment = seedClient.createAssignment(for: course)
        seedClient.submit(assignment: assignment, context: ContextModel(.course, id: course.id), as: student)
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: student)

        page.assertVisible(.submittedText)
        page.assertText(.submittedText, equals: "Successfully submitted!")
    }

    func testGradeCellShowsDialWhenGraded() {
        let assignment = seedClient.createAssignment(for: course, pointsPossible: 100)
        seedClient.submit(assignment: assignment, context: ContextModel(.course, id: course.id), as: student)
        seedClient.gradeSubmission(course: course, assignment: assignment, userID: student.id, as: teacher, grade: "90")
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: student)
        page.select(.gradeCircle).assertText(equals: "90 out of 100 points possible")
    }

    func testDisplayGradeAs() {
        let assignment = seedClient.createAssignment(for: course, pointsPossible: 10, gradingType: .percent)
        seedClient.submit(assignment: assignment, context: ContextModel(.course, id: course.id), as: student)
        seedClient.gradeSubmission(course: course, assignment: assignment, userID: student.id, as: teacher, grade: "80%")
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: student)
        page.select(.gradeCircle).assertText(equals: "8 out of 10 points possible")
        page.select(.gradeDisplayGrade).assertText(equals: "80%")
    }

    func testGradeCellShowsLatePenalty() {
        seedClient.createLatePolicy(for: course, as: teacher, lateSubmissionDeductionEnabled: true, lateSubmissionDeduction: 5, lateSubmissionInterval: .day)
        let dueDate = Date(timeIntervalSinceNow: -10000) // less than 1 day should deduct 5 points
        let assignment = seedClient.createAssignment(for: course, pointsPossible: 100, dueAt: dueDate)
        seedClient.submit(assignment: assignment, context: ContextModel(.course, id: course.id), as: student)
        seedClient.gradeSubmission(course: course, assignment: assignment, userID: student.id, as: teacher, grade: "90")
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: student)
        page.select(.gradeLatePenalty).assertText(equals: "Late penalty (-5 pts)")
    }

    func testViewSubmissionButtonWorksWithNoSubmission() {
        let assignment = seedClient.createAssignment(for: course, pointsPossible: 10, gradingType: .points)
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: student)
        page.tap(.viewSubmissionButton)
        submissionDetailsPage.assertExists(.emptySubmitButton)
    }

    func testSubmissionButtonNavigatesToSubmission() {
        let assignment = seedClient.createAssignment(for: course, pointsPossible: 10, gradingType: .points)
        seedClient.submit(assignment: assignment, context: ContextModel(.course, id: course.id), as: student)
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: student)
        page.tap(.viewSubmissionButton)
        submissionDetailsPage.assertVisible(.attemptPickerToggle)
    }

    func testSubmitUrlSubmission() {
        let assignment = seedClient.createAssignment(for: course, submissionTypes: [.online_url])
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: student)
        page.assertText(.submitAssignmentButton, equals: "Submit Assignment")
        page.tap(.submitAssignmentButton)
        page.assertHidden(.submitAssignmentButton)
    }

    func testSubmitOnlineUpload() {
        #if !(targetEnvironment(simulator))
        let assignment = seedClient.createAssignment(for: course, submissionTypes: [.online_upload])
        launch("/courses/\(course.id)/assignments/\(assignment.id)", as: student)
        page.tap(.submitAssignmentButton)
        filePicker.assertEnabled(.submitButton, false)
        filePicker.tap(.cameraButton)
        capturePhoto()
        filePicker.assertEnabled(.submitButton, true)
        filePicker.tap(.submitButton)
        filePicker.assertExists(.submitButton, false)
        #endif
    }
}
