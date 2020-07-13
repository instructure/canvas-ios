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

import Foundation
@testable import Student
import XCTest
@testable import TestsFoundation
import Core

class AssignmentDetailsViewControllerTests: StudentTestCase {
    var courseID = "1"
    var assignmentID = "1"
    var viewController: AssignmentDetailsViewController!
    var prevSpeed: Float = 1

    override func setUp() {
        super.setUp()
        viewController = AssignmentDetailsViewController.create(courseID: courseID, assignmentID: assignmentID)
        prevSpeed = UIApplication.shared.keyWindow?.layer.speed ?? 1
        UIApplication.shared.keyWindow?.layer.speed = 100
    }

    override func tearDown() {
        UIApplication.shared.keyWindow?.layer.speed = prevSpeed
        super.tearDown()
    }

    func load() {
        XCTAssertNotNil(viewController.view)
    }

    func testViewDidLoad() {
        load()

        XCTAssertEqual(viewController.titleSubtitleView.title, "Assignment Details")
        XCTAssertEqual(viewController.submitAssignmentButton.alpha, 0.0)
        XCTAssertEqual(viewController.scrollviewInsetConstraint.constant, 0.0)
        XCTAssertEqual(viewController.dueSection?.header.text, "Due")
        XCTAssertEqual(viewController.submissionTypesSection?.header.text, "Submission Types")
        XCTAssertEqual(viewController.fileTypesSection?.header.text, "File Types")
        XCTAssertEqual(viewController.attemptsHeadingLabel.text, "Attempts")
        XCTAssertEqual(viewController.gradeHeadingLabel?.text, "Grade")
        XCTAssertEqual(viewController.descriptionHeadingLabel?.text, "Description")
        XCTAssertEqual(viewController.quizAttemptsLabel?.text, "Allowed Attempts:")
        XCTAssertEqual(viewController.quizHeadingLabel?.text, "Settings")
        XCTAssertEqual(viewController.quizQuestionsLabel?.text, "Questions:")
        XCTAssertEqual(viewController.quizTimeLimitLabel?.text, "Time Limit:")
        XCTAssertEqual(viewController.submittedLabel?.text, "Successfully submitted!")
        XCTAssertEqual(viewController.submittedDetailsLabel?.text, "Your submission is now waiting to be graded.")
        XCTAssertEqual(viewController.submissionButton?.title(for: .normal), "Submission & Rubric")
        XCTAssertNotNil(viewController.lockedIconImageView.image)
    }

    func testUpdateNavBar() {
        load()

        _ = UINavigationController(rootViewController: viewController)

        viewController.updateNavBar(subtitle: "hello", backgroundColor: .red)
        XCTAssertEqual(viewController.titleSubtitleView.subtitle, "hello")
        XCTAssertEqual(viewController.navigationController?.navigationBar.barTintColor, .red)
    }

    func testShowSubmitAssignmentButton() {
        load()

        viewController.showSubmitAssignmentButton(title: "hello")
        XCTAssertEqual(viewController.submitAssignmentButton.title(for: .normal), "hello")
        XCTAssertEqual(viewController.submitAssignmentButton.alpha, 1.0)
        XCTAssertEqual(viewController.scrollviewInsetConstraint.constant, 75.0)

        viewController.showSubmitAssignmentButton(title: nil)
        XCTAssertEqual(viewController.scrollviewInsetConstraint.constant, 0.0)
        XCTAssertEqual(viewController.submitAssignmentButton.alpha, 0)
    }

    func testHideDescription() {
        mockCourse()
        let a = APIAssignment.make( unlock_at: Date().addDays(1), locked_for_user: true )
        api.mock(viewController.presenter!.assignments, value: a)

        load()

        XCTAssertEqual(viewController.descriptionView?.isHidden, true)
        XCTAssertEqual(viewController.descriptionHeadingLabel?.isHidden, true)
    }

    func testShowDescription() {
        mockCourse()
        let a = APIAssignment.make()
        api.mock(viewController.presenter!.assignments, value: a)

        load()

        XCTAssertEqual(viewController.descriptionView?.isHidden, false)
        XCTAssertEqual(viewController.descriptionHeadingLabel?.isHidden, false)
    }

    func testGradeCellNotHidden() {
        load()
        XCTAssertEqual(viewController.gradeSection?.isHidden, false)
    }

    func testHideGradeCell() {
        mockCourse()
        let a = APIAssignment.make(submission: nil)
        api.mock(viewController.presenter!.assignments, value: a)

        load()

        XCTAssertEqual(viewController.gradeSection?.isHidden, true)
        XCTAssertEqual(viewController.gradeStatisticGraphView?.isHidden, true)
    }

    func testUpdateQuizSettings() {
        mockCourse()
        let q = APIQuiz.make(allowed_attempts: 2, question_count: 3, time_limit: 4)
        let qq = Quiz.make(from: q )
        let a = APIAssignment.make( quiz_id: ID(qq.id) )
        api.mock(viewController.presenter!.assignments, value: a)

        load()

        XCTAssertEqual(viewController.quizView?.isHidden, false)
        XCTAssertEqual(viewController.quizAttemptsValueLabel?.text, "2")
        XCTAssertEqual(viewController.quizQuestionsValueLabel?.text, "3")
        XCTAssertEqual(viewController.quizTimeLimitValueLabel?.text, "4min")

        viewController.updateQuizSettings(nil)
        XCTAssertEqual(viewController.quizView?.isHidden, true)
    }

    func testUpdateQuizSettingsNoQuiz() {
        mockCourse()
        let a = APIAssignment.make( quiz_id: nil )
        api.mock(viewController.presenter!.assignments, value: a)

        load()

        XCTAssertEqual(viewController.quizView?.isHidden, true)
    }

    func testUpdateGradeCellNoSubmission() {
        mockCourse()
        let a = APIAssignment.make( submission: nil )
        api.mock(viewController.presenter!.assignments, value: a)

        load()

        XCTAssertTrue(viewController.gradeSection?.isHidden == true)
    }

    func testUpdateGradeCellWorkflowStateUnsubmitted() {
        mockCourse()
        let a = APIAssignment.make( submission: .make(
        grade: "10",
        score: 10,
        submission_type: .online_text_entry,
        workflow_state: .unsubmitted))
        api.mock(viewController.presenter!.assignments, value: a)

        load()

        XCTAssertTrue(viewController.gradeSection?.isHidden == true)
    }

    func testUpdateGradeCellWorkflowStateNeedsGrading() {
        mockCourse()
        let assignment = APIAssignment.make(
            id: ID(assignmentID),
            course_id: ID(courseID),
            submission: .make(
                grade: "10",
                score: nil,
                submission_type: .online_text_entry,
                workflow_state: .graded,
                grade_matches_current_submission: false)
        )
        api.mock(viewController.presenter!.assignments, value: assignment)
        load()
        XCTAssertTrue(viewController.submittedView?.isHidden == false)
    }

    func testUpdateGradeCellWhenThereIsUploadState() {
        let aa = APIAssignment.make( submission: .make(
            grade: "10",
            score: 10,
            submission_type: .online_text_entry,
            workflow_state: .graded))

        setupFileForSubmittedLabel(uploadError: "error", apiAssignment: aa)
        load()

        XCTAssertEqual(viewController.submittedLabel?.text, "Submission Failed")
        XCTAssertEqual(viewController.gradeSection?.isHidden, false)
        XCTAssertEqual(viewController.gradeCellDivider?.isHidden, false)
        XCTAssertEqual(viewController.gradedView?.isHidden, true)
        XCTAssertEqual(viewController.gradeStatisticGraphView?.isHidden, true)
        XCTAssertEqual(viewController.submittedView?.isHidden, false)
        XCTAssertEqual(viewController.fileSubmissionButton?.isHidden, false)
        XCTAssertEqual(viewController.submittedDetailsLabel?.isHidden, true)
    }

    func testUpdateGradeCellWhenThereIsUploadStateAndUnsubmitted() {
        let aa = APIAssignment.make(submission: .make(
            grade: "10",
            score: 10,
            submission_type: .online_text_entry,
            workflow_state: .unsubmitted))

        setupFileForSubmittedLabel(uploadError: "error", apiAssignment: aa)
        load()

        XCTAssertEqual(viewController.submittedLabel?.text, "Submission Failed")
        XCTAssertEqual(viewController.gradeSection?.isHidden, false)
        XCTAssertEqual(viewController.gradeCellDivider?.isHidden, false)
        XCTAssertEqual(viewController.gradedView?.isHidden, true)
        XCTAssertEqual(viewController.gradeStatisticGraphView?.isHidden, true)
        XCTAssertEqual(viewController.submittedView?.isHidden, false)
        XCTAssertEqual(viewController.fileSubmissionButton?.isHidden, false)
        XCTAssertEqual(viewController.submittedDetailsLabel?.isHidden, true)
    }

    func testUpdateGradeCell() {
        let aa = APIAssignment.make( submission: .make(
            grade: "10",
            score: 10,
            submission_type: .online_text_entry,
            workflow_state: .graded))
        Assignment.make(from: aa, in: databaseClient)

        load()

        XCTAssertEqual(viewController.submittedLabel?.text, "Successfully submitted!")
        XCTAssertEqual(viewController.fileSubmissionButton?.isHidden, true)
        XCTAssertEqual(viewController.submittedView?.isHidden, true)
        XCTAssertEqual(viewController.submittedLabel?.text, "Successfully submitted!")
    }

    func testUpdateUpdateSubmissionLabelsFailedState() {
        setupFileForSubmittedLabel(uploadError: "error")
        load()

        XCTAssertEqual(viewController.submittedLabel?.text, "Submission Failed")
        XCTAssertEqual(viewController.fileSubmissionButton?.title(for: .normal), "Tap to view details")
    }

    func testUpdateUpdateSubmissionLabelsUploadingState() {
        setupFileForSubmittedLabel(removeID: true, taskID: "1")
        load()

        XCTAssertEqual(viewController.submittedLabel?.text, "Submission Uploading...")
        XCTAssertEqual(viewController.fileSubmissionButton?.title(for: .normal), "Tap to view progress")
    }

    func testUpdateUpdateSubmissionLabelsStagedState() {
        setupFileForSubmittedLabel(removeID: true)
        load()

        XCTAssertEqual(viewController.submittedLabel?.text, "Submission In Progress...")
        XCTAssertEqual(viewController.fileSubmissionButton?.title(for: .normal), "Tap to view progress")
    }

    func testNeedsGradingAndGraded() {
        let course = APICourse.make(id: ID(courseID))
        api.mock(viewController.presenter!.courses, value: course)
        let assignment = APIAssignment.make(
            id: ID(assignmentID),
            course_id: ID(courseID),
            submission: .make(
                grade: "10",
                score: 10,
                submission_type: .discussion_topic,
                workflow_state: .graded,
                grade_matches_current_submission: false
            )
        )
        api.mock(viewController.presenter!.assignments, value: assignment)
        load()
        drainMainQueue()
        XCTAssertTrue(viewController.submittedView!.isHidden)
        XCTAssertFalse(viewController.gradeSection!.isHidden)
        XCTAssertFalse(viewController.gradedView!.isHidden)
    }

    func testGradedAndResubmitted() {
        let course = APICourse.make(id: ID(courseID))
        api.mock(viewController.presenter!.courses, value: course)
        let assignment = APIAssignment.make(
            id: ID(assignmentID),
            course_id: ID(courseID),
            submission: .make(
                grade: "10",
                score: 10,
                submission_type: .discussion_topic,
                workflow_state: .submitted,
                grade_matches_current_submission: false
            )
        )
        api.mock(viewController.presenter!.assignments, value: assignment)
        load()
        drainMainQueue()
        XCTAssertTrue(viewController.submittedView!.isHidden)
        XCTAssertFalse(viewController.gradeSection!.isHidden)
        XCTAssertFalse(viewController.gradedView!.isHidden)
    }

    func testNeedsGrading() {
        let course = APICourse.make(id: ID(courseID))
        api.mock(viewController.presenter!.courses, value: course)
        let assignment = APIAssignment.make(
            id: ID(assignmentID),
            course_id: ID(courseID),
            submission: .make(
                score: nil,
                submission_type: .discussion_topic,
                workflow_state: .pending_review
            )
        )
        api.mock(viewController.presenter!.assignments, value: assignment)
        load()
        drainMainQueue()
        XCTAssertFalse(viewController.submittedView!.isHidden)
        XCTAssertFalse(viewController.gradeSection!.isHidden)
        XCTAssertTrue(viewController.gradeStatisticGraphView!.isHidden)
        XCTAssertTrue(viewController.gradedView!.isHidden)
    }

    func testNeedsGradingAndExcused() {
        let course = APICourse.make(id: ID(courseID))
        api.mock(viewController.presenter!.courses, value: course)
        let assignment = APIAssignment.make(
            id: ID(assignmentID),
            course_id: ID(courseID),
            submission: .make(
                excused: true,
                workflow_state: .pending_review
            )
        )
        api.mock(viewController.presenter!.assignments, value: assignment)
        load()
        drainMainQueue()
        XCTAssertTrue(viewController.submittedView!.isHidden)
        XCTAssertFalse(viewController.gradeSection!.isHidden)
        XCTAssertFalse(viewController.gradedView!.isHidden)
    }

    func testGraded() {
        let course = APICourse.make(id: ID(courseID))
        api.mock(viewController.presenter!.courses, value: course)
        let assignment = APIAssignment.make(
            id: ID(assignmentID),
            course_id: ID(courseID),
            submission: .make(
                grade: "10",
                score: 10,
                submission_type: .discussion_topic,
                workflow_state: .graded
            )
        )
        api.mock(viewController.presenter!.assignments, value: assignment)
        load()
        drainMainQueue()
        XCTAssertTrue(viewController.submittedView!.isHidden)
        XCTAssertFalse(viewController.gradeSection!.isHidden)
        XCTAssertTrue(viewController.gradeStatisticGraphView!.isHidden)
        XCTAssertFalse(viewController.gradedView!.isHidden)
    }
    
    func testGradedWithScoreStatistics() {
        let course = APICourse.make(id: ID(courseID))
        api.mock(viewController.presenter!.courses, value: course)
        let assignment = APIAssignment.make(
            id: ID(assignmentID),
            course_id: ID(courseID),
            submission: .make(
                grade: "10",
                score: 10,
                submission_type: .discussion_topic,
                workflow_state: .graded
            ),
            score_statistics: APIAssignmentScoreStatistics.make(mean: 5.0, min: 1.0, max: 10.0)
        )
        api.mock(viewController.presenter!.assignments, value: assignment)
        load()
        drainMainQueue()
        XCTAssertTrue(viewController.submittedView!.isHidden)
        XCTAssertFalse(viewController.gradeSection!.isHidden)
        XCTAssertFalse(viewController.gradeStatisticGraphView!.isHidden)
        XCTAssertFalse(viewController.gradedView!.isHidden)
    }

    func testUnsubmittedAndGradeRemoved() {
        let course = APICourse.make(id: ID(courseID))
        api.mock(viewController.presenter!.courses, value: course)
        let assignment = APIAssignment.make(
            id: ID(assignmentID),
            course_id: ID(courseID),
            submission: .make(
                grade: nil,
                score: nil,
                submission_type: nil,
                workflow_state: .graded
            )
        )
        api.mock(viewController.presenter!.assignments, value: assignment)
        load()
        drainMainQueue()
        XCTAssertTrue(viewController.submittedView!.isHidden)
        XCTAssertTrue(viewController.gradeSection!.isHidden)
        XCTAssertTrue(viewController.gradedView!.isHidden)

    }

    func setupFileForSubmittedLabel(removeID: Bool = false, taskID: String? = nil, uploadError: String? = nil, apiAssignment: APIAssignment? = nil) {
        let course = APICourse.make(id: ID(courseID))
        api.mock(viewController.presenter!.courses, value: course)
        let assignment = apiAssignment ?? APIAssignment.make(
            id: ID(assignmentID),
            course_id: ID(courseID),
            submission: .make(
                grade: "10",
                score: 10,
                submission_type: .discussion_topic,
                workflow_state: .graded,
                grade_matches_current_submission: false
            )
        )
        File.make(assignmentID: assignmentID, batchID: "assignment-\(assignmentID)",
            removeID: removeID, taskID: taskID, userID: "1", uploadError: uploadError)
        api.mock(viewController.presenter!.assignments, value: assignment)
        XCTAssertEqual(viewController.presenter?.onlineUpload.count, 1)
    }

    func mockCourse() {
        let course = APICourse.make(id: ID(courseID))
        api.mock(viewController.presenter!.courses, value: course)
    }
}
