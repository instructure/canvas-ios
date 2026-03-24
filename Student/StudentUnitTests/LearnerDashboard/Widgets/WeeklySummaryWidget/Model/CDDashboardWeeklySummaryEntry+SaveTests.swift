//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import XCTest
@testable import Student

final class CDDashboardWeeklySummaryEntrySaveTests: StudentTestCase {

    private let weekStart = Date(timeIntervalSince1970: 0)

    // MARK: - saveMissing

    func test_saveMissing_mapsBasicFields() {
        let due = Date(timeIntervalSince1970: 1000)
        let assignment = APIAssignment.make(
            course_id: "42",
            due_at: due,
            id: "a1",
            name: "Math HW",
            points_possible: 50
        )

        let entry = CDDashboardWeeklySummaryEntry.saveMissing(
            assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertEqual(entry.assignmentId, "a1")
        XCTAssertEqual(entry.weekStart, weekStart)
        XCTAssertEqual(entry.category, .missing)
        XCTAssertEqual(entry.courseId, "42")
        XCTAssertEqual(entry.title, "Math HW")
        XCTAssertEqual(entry.date, due)
        XCTAssertEqual(entry.pointsPossible, 50)
        XCTAssertNil(entry.grade)
        XCTAssertNil(entry.score)
        XCTAssertFalse(entry.excused)
        XCTAssertNil(entry.submissionStatus)
    }

    func test_saveMissing_setsIsQuizLtiTrueWhenQuizId() {
        let assignment = APIAssignment.make(quiz_id: "q1")

        let entry = CDDashboardWeeklySummaryEntry.saveMissing(
            assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertTrue(entry.isQuizLti)
    }

    func test_saveMissing_setsIsQuizLtiTrueWhenIsQuizLtiAssignment() {
        let assignment = APIAssignment.make(is_quiz_lti_assignment: true)

        let entry = CDDashboardWeeklySummaryEntry.saveMissing(
            assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertTrue(entry.isQuizLti)
    }

    func test_saveMissing_setsIsQuizLtiFalseForRegularAssignment() {
        let assignment = APIAssignment.make(is_quiz_lti_assignment: false, quiz_id: nil)

        let entry = CDDashboardWeeklySummaryEntry.saveMissing(
            assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertFalse(entry.isQuizLti)
    }

    func test_saveMissing_storesAssignmentWeight() {
        let assignment = APIAssignment.make()

        let entry = CDDashboardWeeklySummaryEntry.saveMissing(
            assignment,
            weekStart: weekStart,
            gradeWeight: 0.25,
            in: databaseClient
        )

        XCTAssertEqual(entry.gradeWeight, 0.25)
    }

    // MARK: - saveDue

    func test_saveDue_mapsBasicFields() {
        let due = Date(timeIntervalSince1970: 2000)
        let plannable = APIPlannable.make(
            course_id: "99",
            plannable_id: "p1",
            plannable: .make(title: "Essay", points_possible: 100),
            plannable_date: due
        )

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: APIAssignment.make(id: "p1"),
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertEqual(entry.assignmentId, "p1")
        XCTAssertEqual(entry.weekStart, weekStart)
        XCTAssertEqual(entry.category, .due)
        XCTAssertEqual(entry.courseId, "99")
        XCTAssertEqual(entry.title, "Essay")
        XCTAssertEqual(entry.date, due)
        XCTAssertEqual(entry.pointsPossible, 100)
    }

    func test_saveDue_storesParentAssignmentIdAsRouteAssignmentId() {
        let plannable = APIPlannable.make(plannable_id: "50883")

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: APIAssignment.make(id: "50882"),
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertEqual(entry.assignmentId, "50883")
        XCTAssertEqual(entry.routeAssignmentId, "50882")
    }

    func test_saveDue_isQuizLtiFalseWhenAssignmentHasNoQuizId() {
        let plannable = APIPlannable.make(plannable_id: "a1")

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: APIAssignment.make(id: "a1"),
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertFalse(entry.isQuizLti)
    }

    func test_saveDue_isQuizLtiTrueWhenAssignmentHasQuizId() {
        let plannable = APIPlannable.make(plannable_id: "a1")
        let assignment = APIAssignment.make(id: "a1", quiz_id: "q1")

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertTrue(entry.isQuizLti)
    }

    func test_saveDue_isQuizLtiTrueWhenAssignmentIsQuizLti() {
        let plannable = APIPlannable.make(plannable_id: "a1")
        let assignment = APIAssignment.make(id: "a1", is_quiz_lti_assignment: true)

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertTrue(entry.isQuizLti)
    }

    func test_saveDue_submissionStatusIsGradedWhenScoredAndWorkflowStateIsGraded() {
        let submission = APISubmission.make(score: 90, workflow_state: .graded)
        let plannable = APIPlannable.make(plannable_id: "a1")
        let assignment = APIAssignment.make(id: "a1", submission: submission)

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertEqual(entry.submissionStatus, .graded)
    }

    func test_saveDue_submissionStatusIsNotGradedWhenScoreIsPresentButWorkflowStateIsNotGraded() {
        let submission = APISubmission.make(score: 90, submitted_at: Clock.now, workflow_state: .submitted)
        let plannable = APIPlannable.make(plannable_id: "a1")
        let assignment = APIAssignment.make(id: "a1", submission: submission)

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertEqual(entry.submissionStatus, .submitted)
    }

    func test_saveDue_submissionStatusIsNotGradedWhenWorkflowStateIsGradedButScoreIsNil() {
        let submission = APISubmission.make(score: nil, submitted_at: Clock.now, workflow_state: .graded)
        let plannable = APIPlannable.make(plannable_id: "a1")
        let assignment = APIAssignment.make(id: "a1", submission: submission)

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertEqual(entry.submissionStatus, .submitted)
    }

    func test_saveDue_submissionStatusIsSubmittedWhenSubmittedAtIsSet() {
        let submission = APISubmission.make(score: nil, submitted_at: Clock.now, workflow_state: .submitted)
        let plannable = APIPlannable.make(plannable_id: "a1")
        let assignment = APIAssignment.make(id: "a1", submission: submission)

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertEqual(entry.submissionStatus, .submitted)
    }

    func test_saveDue_submissionStatusIsSubmittedWhenWorkflowStateIsPendingReview() {
        let submission = APISubmission.make(score: nil, submitted_at: nil, workflow_state: .pending_review)
        let plannable = APIPlannable.make(plannable_id: "a1")
        let assignment = APIAssignment.make(id: "a1", submission: submission)

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertEqual(entry.submissionStatus, .submitted)
    }

    func test_saveDue_submissionStatusIsNilWhenSubmittedAtIsNilAndWorkflowStateIsSubmitted() {
        let submission = APISubmission.make(submitted_at: nil, workflow_state: .submitted)
        let plannable = APIPlannable.make(plannable_id: "a1")
        let assignment = APIAssignment.make(id: "a1", submission: submission)

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertNil(entry.submissionStatus)
    }

    func test_saveDue_submissionStatusIsNilWhenUnsubmitted() {
        let submission = APISubmission.make(submitted_at: nil, workflow_state: .unsubmitted)
        let plannable = APIPlannable.make(plannable_id: "a1")
        let assignment = APIAssignment.make(id: "a1", submission: submission)

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertNil(entry.submissionStatus)
    }

    func test_saveDue_storesReplyToTopicCheckpointStep() {
        let plannable = APIPlannable.make(
            plannable_id: "a1",
            plannable: .make(sub_assignment_tag: "reply_to_topic")
        )

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: APIAssignment.make(id: "a1"),
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertEqual(entry.discussionCheckpointStep, .replyToTopic)
    }

    func test_saveDue_storesRequiredRepliesCheckpointStep() {
        let plannable = APIPlannable.make(
            plannable_id: "a1",
            plannable: .make(sub_assignment_tag: "reply_to_entry"),
            details: .make(reply_to_entry_required_count: 3)
        )

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: APIAssignment.make(id: "a1"),
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertEqual(entry.discussionCheckpointStep, .requiredReplies(3))
    }

    func test_saveDue_checkpointStepIsNilForRegularAssignment() {
        let plannable = APIPlannable.make(plannable_id: "a1")

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: APIAssignment.make(id: "a1"),
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertNil(entry.discussionCheckpointStep)
    }

    func test_saveDue_usesSubAssignmentGradeAndScoreWhenTagMatches() {
        let subSubmission = APISubAssignmentSubmission.make(
            sub_assignment_tag: "reply_to_topic",
            published_score: 5,
            published_grade: "5"
        )
        let submission = APISubmission.make(
            grade: "8",
            score: 8,
            sub_assignment_submissions: [subSubmission]
        )
        let plannable = APIPlannable.make(
            plannable_id: "sub1",
            plannable: .make(sub_assignment_tag: "reply_to_topic")
        )
        let assignment = APIAssignment.make(id: "a1", submission: submission)

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertEqual(entry.grade, "5")
        XCTAssertEqual(entry.score, 5)
    }

    func test_saveDue_submissionStatusIsGradedForSubAssignment() {
        let subSubmission = APISubAssignmentSubmission.make(
            sub_assignment_tag: "reply_to_topic",
            submitted_at: Clock.now,
            published_score: 5
        )
        let submission = APISubmission.make(sub_assignment_submissions: [subSubmission])
        let plannable = APIPlannable.make(
            plannable_id: "sub1",
            plannable: .make(sub_assignment_tag: "reply_to_topic")
        )
        let assignment = APIAssignment.make(id: "a1", submission: submission)

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertEqual(entry.submissionStatus, .graded)
    }

    func test_saveDue_submissionStatusIsSubmittedForSubAssignment() {
        let subSubmission = APISubAssignmentSubmission.make(
            sub_assignment_tag: "reply_to_topic",
            submitted_at: Clock.now,
            published_score: nil
        )
        let submission = APISubmission.make(sub_assignment_submissions: [subSubmission])
        let plannable = APIPlannable.make(
            plannable_id: "sub1",
            plannable: .make(sub_assignment_tag: "reply_to_topic")
        )
        let assignment = APIAssignment.make(id: "a1", submission: submission)

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertEqual(entry.submissionStatus, .submitted)
    }

    func test_saveDue_submissionStatusIsNilWhenSubAssignmentNotSubmitted() {
        let subSubmission = APISubAssignmentSubmission.make(
            sub_assignment_tag: "reply_to_topic",
            submitted_at: nil,
            published_score: nil
        )
        let submission = APISubmission.make(sub_assignment_submissions: [subSubmission])
        let plannable = APIPlannable.make(
            plannable_id: "sub1",
            plannable: .make(sub_assignment_tag: "reply_to_topic")
        )
        let assignment = APIAssignment.make(id: "a1", submission: submission)

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertNil(entry.submissionStatus)
    }

    func test_saveDue_fallsBackToParentSubmissionWhenNoSubAssignmentTag() {
        let subSubmission = APISubAssignmentSubmission.make(
            sub_assignment_tag: "reply_to_topic",
            published_score: 5,
            published_grade: "5"
        )
        let submission = APISubmission.make(
            grade: "8",
            score: 8,
            workflow_state: .graded,
            sub_assignment_submissions: [subSubmission]
        )
        let plannable = APIPlannable.make(plannable_id: "a1")
        let assignment = APIAssignment.make(id: "a1", submission: submission)

        let entry = CDDashboardWeeklySummaryEntry.saveDue(
            plannable,
            assignment: assignment,
            weekStart: weekStart,
            gradeWeight: nil,
            in: databaseClient
        )

        XCTAssertEqual(entry.grade, "8")
        XCTAssertEqual(entry.score, 8)
        XCTAssertEqual(entry.submissionStatus, .graded)
    }

    // MARK: - saveGrade

    func test_saveGrade_mapsBasicFields() {
        let gradedAt = Date(timeIntervalSince1970: 3000)
        let submission = makeSubmissionNode(id: "s1", grade: "90", score: 90, gradedAt: gradedAt)

        let entry = CDDashboardWeeklySummaryEntry.saveGrade(
            submission,
            courseId: "c5",
            gradedAt: gradedAt,
            weekStart: weekStart,
            restrictQuantitativeData: false,
            in: databaseClient
        )

        XCTAssertEqual(entry.assignmentId, "assignment1")
        XCTAssertEqual(entry.weekStart, weekStart)
        XCTAssertEqual(entry.category, .newGrades)
        XCTAssertEqual(entry.courseId, "c5")
        XCTAssertEqual(entry.grade, "90")
        XCTAssertEqual(entry.score, 90)
        XCTAssertFalse(entry.excused)
        XCTAssertNil(entry.gradeWeight)
        XCTAssertNil(entry.submissionStatus)
    }

    func test_saveGrade_storesRestrictQuantitativeData() {
        let gradedAt = Date(timeIntervalSince1970: 1000)
        let submission = makeSubmissionNode(gradedAt: gradedAt)

        let entry = CDDashboardWeeklySummaryEntry.saveGrade(
            submission,
            courseId: "c1",
            gradedAt: gradedAt,
            weekStart: weekStart,
            restrictQuantitativeData: true,
            in: databaseClient
        )

        XCTAssertTrue(entry.restrictQuantitativeData)
    }

    // MARK: - Private helpers

    private func makeSubmissionNode(
        id: String = "s1",
        grade: String? = "A",
        score: Double? = 100,
        gradedAt: Date = Clock.now
    ) -> GetRecentGradedSubmissionsRequest.Response.SubmissionNode {
        let assignment = GetRecentGradedSubmissionsRequest.Response.AssignmentNode(
            _id: "assignment1",
            name: "Final Exam",
            htmlUrl: nil,
            pointsPossible: 100,
            gradingType: "points"
        )
        return GetRecentGradedSubmissionsRequest.Response.SubmissionNode(
            _id: id,
            score: score,
            grade: grade,
            excused: false,
            gradeHidden: false,
            gradedAt: gradedAt,
            assignment: assignment
        )
    }
}
