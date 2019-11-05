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
import TestsFoundation
import Core

class AssignmentDetailsViewControllerTests: PersistenceTestCase {
    var courseID = "1"
    var assignmentID = "1"
    var viewController: AssignmentDetailsViewController!
    var prevSpeed: Float = 1

    override func setUp() {
        super.setUp()
        env.mockStore = false
        viewController = AssignmentDetailsViewController.create(env: env, courseID: courseID, assignmentID: assignmentID)
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
        XCTAssertEqual(viewController.loadingView?.color.hex, "#008EE2")
        XCTAssertEqual(viewController.submitAssignmentButton.alpha, 0.0)
        XCTAssertEqual(viewController.scrollviewInsetConstraint.constant, 0.0)
        XCTAssertEqual(viewController.dueSection?.header.text, "Due")
        XCTAssertEqual(viewController.submissionTypesSection?.header.text, "Submission Types")
        XCTAssertEqual(viewController.fileTypesSection?.header.text, "File Types")
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

        let _ = UINavigationController(rootViewController: viewController)

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

    func testShowDescription() {
        load()

        viewController.showDescription(false)
        XCTAssertEqual(viewController.descriptionView?.isHidden, true)
        XCTAssertEqual(viewController.descriptionHeadingLabel?.isHidden, true)

        viewController.showDescription(true)
        XCTAssertEqual(viewController.descriptionView?.isHidden, false)
        XCTAssertEqual(viewController.descriptionHeadingLabel?.isHidden, false)
    }

    func testHideGradeCell() {
        load()

        XCTAssertEqual(viewController.gradeSection?.isHidden, false)
        viewController.hideGradeCell()
        XCTAssertEqual(viewController.gradeSection?.isHidden, true)
    }

    func testHandleLink() {
        load()
        let url = URL(string: "/courses/165")!
        XCTAssertTrue(viewController.handleLink(url))
        XCTAssertTrue(router.lastRoutedTo(url))
    }

    func testUpdateQuizSettings() {
        let q = Quiz.make(from: APIQuiz.make(allowed_attempts: 2, question_count: 3, time_limit: 4), courseID: "1", in: databaseClient)

        load()

        viewController.updateQuizSettings(q)

        XCTAssertEqual(viewController.quizView?.isHidden, false)
        XCTAssertEqual(viewController.quizAttemptsValueLabel?.text, "2")
        XCTAssertEqual(viewController.quizQuestionsValueLabel?.text, "3")
        XCTAssertEqual(viewController.quizTimeLimitValueLabel?.text, "4min")

        viewController.updateQuizSettings(nil)
        XCTAssertEqual(viewController.quizView?.isHidden, true)
    }

    func testCenterLockedIconContainerDelayedStart() {
        load()

        viewController.scrollView?.contentSize = CGSize(width: 320, height: 800)
        viewController.centerLockedIconContainerDelayedStart()

        XCTAssertEqual(viewController.lockedIconContainerView.alpha, 1.0)
        XCTAssertEqual(viewController.lockedIconHeight.constant, 144)
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
}
