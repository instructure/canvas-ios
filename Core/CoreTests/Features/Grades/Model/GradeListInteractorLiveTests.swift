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

@testable import Core
import Foundation
import TestsFoundation
import XCTest

class GradeListInteractorLiveTests: CoreTestCase {
    lazy var groups: [APIAssignmentGroup] = [
        .make(
            id: "1",
            name: "Worksheets",
            position: 2,
            assignments: [
                .make(
                    assignment_group_id: "1",
                    course_id: "1",
                    due_at: DateComponents(calendar: .current, year: 2020, month: 1, day: 1).date,
                    grading_type: .points,
                    id: "1",
                    name: "Complex Numbers",
                    points_possible: 25,
                    submission: APISubmission.make(
                        assignment_id: "1",
                        attempt: 1,
                        grade: "20",
                        grade_matches_current_submission: true,
                        id: "1",
                        late: true,
                        late_policy_status: .late,
                        points_deducted: 2,
                        score: 20,
                        submitted_at: DateComponents(calendar: .current, year: 2020, month: 1, day: 2).date,
                        user_id: currentSession.userID,
                        workflow_state: .submitted
                    )
                )
            ]
        ),
        .make(
            id: "2",
            name: "Essays",
            position: 1,
            assignments: [
                .make(
                    assignment_group_id: "2",
                    course_id: "1",
                    id: "2",
                    name: "Proof that proofs are useful"
                )
            ]
        ),
        .make(
            id: "3",
            name: "Paper Assignments Group",
            position: 3,
            assignments: [
                .make(
                    assignment_group_id: "3",
                    course_id: "1",
                    id: "3",
                    name: "Paper Assignment",
                    submission: APISubmission.make(
                        assignment: .make(submission_types: [.on_paper]),
                        assignment_id: "1",
                        attempt: 1,
                        grade: "20",
                        grade_matches_current_submission: true,
                        id: "1",
                        late: true,
                        late_policy_status: .missing,
                        points_deducted: 2,
                        score: 20,
                        submission_type: .on_paper,
                        submitted_at: DateComponents(calendar: .current, year: 2020, month: 1, day: 2).date,
                        user_id: currentSession.userID,
                        workflow_state: .unsubmitted
                    ),
                    submission_types: [.on_paper]
                )
            ]
        )
    ]

    func mockGrades(gradingPeriodID: String?, score: Double?, grade: String? = nil) {
        api.mock(
            GetEnrollments(
                context: .course("1"),
                userID: currentSession.userID,
                gradingPeriodID: gradingPeriodID,
                types: ["StudentEnrollment"],
                states: [.active, .completed]
            ),
            value: [
                .make(
                    id: "1",
                    course_id: "1",
                    enrollment_state: .active,
                    type: "StudentEnrollment",
                    user_id: currentSession.userID,
                    grades: .make(
                        current_grade: grade,
                        final_grade: grade,
                        current_score: score,
                        final_score: score
                    )
                )
            ]
        )
    }

    override func setUp() {
        super.setUp()
        var assignmentsRequest = GetAssignmentGroupsRequest(
            courseID: "1",
            gradingPeriodID: nil,
            perPage: 100
        )
        api.mock(assignmentsRequest, value: groups)
        assignmentsRequest = GetAssignmentGroupsRequest(
            courseID: "1",
            gradingPeriodID: "1",
            perPage: 100
        )
        api.mock(assignmentsRequest, value: [groups[0]])
        assignmentsRequest = GetAssignmentGroupsRequest(
            courseID: "1",
            gradingPeriodID: "2",
            perPage: 100
        )
        api.mock(assignmentsRequest, value: [groups[1]])
        assignmentsRequest = GetAssignmentGroupsRequest(
            courseID: "1",
            gradingPeriodID: "3",
            perPage: 100
        )
        api.mock(assignmentsRequest, value: [groups[2]])
        api.mock(GetCustomColors(), value: .init(custom_colors: [:]))
        api.mock(
            GetCourse(courseID: "1"),
            value: .make(enrollments: [
                .make(
                    id: nil,
                    course_id: "1",
                    enrollment_state: .active,
                    user_id: currentSession.userID,
                    multiple_grading_periods_enabled: true,
                    current_grading_period_id: "1"
                )
            ])
        )
        api.mock(GetGradingPeriods(courseID: "1"), value: [.make(id: "1")])
        mockGrades(gradingPeriodID: nil, score: 20)
        mockGrades(gradingPeriodID: "1", score: 20)
        mockGrades(gradingPeriodID: "2", score: nil)
        mockGrades(gradingPeriodID: "3", score: 25)
    }

    func testDueDateArrangement() {
        let now = DateComponents(calendar: .current, year: 2024, month: 1, day: 1).date!
        Clock.mockNow(now)

        let past = DateComponents(calendar: .current, year: 2020, month: 1, day: 1).date
        let pastLockAt = DateComponents(calendar: .current, year: 2020, month: 1, day: 3).date
        let upcoming = DateComponents(calendar: .current, year: 2024, month: 03, day: 1).date
        let upcomingLockAt = DateComponents(calendar: .current, year: 2024, month: 03, day: 3).date
        let overdue = DateComponents(calendar: .current, year: 2023, month: 12, day: 1).date
        let overdueLockAt = DateComponents(calendar: .current, year: 2024, month: 1, day: 5).date

        let assignmentGroups: [APIAssignmentGroup] = [
            .make(id: "1", name: "Group A", assignments: [.make(due_at: past, id: "1", lock_at: pastLockAt)]),
            .make(id: "2", name: "Group B", assignments: [.make(due_at: upcoming, id: "2", lock_at: upcomingLockAt)]),
            .make(id: "3", name: "Group C", assignments: [.make(due_at: overdue, id: "3", lock_at: overdueLockAt)])
        ]
        let assignmentsRequest = GetAssignmentGroupsRequest(
            courseID: "1",
            gradingPeriodID: "1",
            perPage: 100
        )
        api.mock(assignmentsRequest, value: assignmentGroups)
        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(arrangeBy: .dueDate, baseOnGradedAssignment: true, gradingPeriodID: nil, ignoreCache: true)
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data.assignmentSections.count, 3)
                    XCTAssertEqual(data.assignmentSections[0].title, "Overdue Assignments")
                    XCTAssertEqual(data.assignmentSections[0].assignments[0].id, "3")
                    XCTAssertEqual(data.assignmentSections[1].title, "Upcoming Assignments")
                    XCTAssertEqual(data.assignmentSections[1].assignments[0].id, "2")
                    XCTAssertEqual(data.assignmentSections[2].title, "Past Assignments")
                    XCTAssertEqual(data.assignmentSections[2].assignments[0].id, "1")

                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()

        Clock.reset()
    }

    func testGroupArrangement() {
        let assignmentGroups: [APIAssignmentGroup] = [
            .make(id: "1", name: "Group A", assignments: [.make(assignment_group_id: "1", id: "1")]),
            .make(id: "2", name: "Group B", assignments: [.make(assignment_group_id: "2", id: "2")]),
            .make(id: "3", name: "Group C", assignments: [
                .make(assignment_group_id: "3", id: "3"),
                .make(assignment_group_id: "3", id: "4")
            ])
        ]
        let assignmentsRequest = GetAssignmentGroupsRequest(
            courseID: "1",
            gradingPeriodID: "1",
            perPage: 100
        )
        api.mock(assignmentsRequest, value: assignmentGroups)
        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(arrangeBy: .groupName, baseOnGradedAssignment: true, gradingPeriodID: "1", ignoreCache: false)
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data.assignmentSections.count, 3)
                    XCTAssertEqual(data.assignmentSections[0].title, "Group A")
                    XCTAssertEqual(data.assignmentSections[0].assignments.count, 1)
                    XCTAssertEqual(data.assignmentSections[1].title, "Group B")
                    XCTAssertEqual(data.assignmentSections[1].assignments.count, 1)
                    XCTAssertEqual(data.assignmentSections[2].title, "Group C")
                    XCTAssertEqual(data.assignmentSections[2].assignments.count, 2)
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testHideTotals() {
        mockGetCourseAPI(
            currentGradingPeriodId: "1",
            hideFinalGrade: true,
            multipleGradingPeriodsEnabled: true
        )

        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(arrangeBy: .groupName, baseOnGradedAssignment: true, gradingPeriodID: "1", ignoreCache: false)
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data.totalGradeText, nil)
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testHideTotalsWithTotalsForAllGradingPeriodIsDisabled() {
        mockGetCourseAPI(
            currentGradingPeriodId: nil,
            hideFinalGrade: true,
            multipleGradingPeriodsEnabled: true
        )

        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(arrangeBy: .groupName, baseOnGradedAssignment: true, gradingPeriodID: nil, ignoreCache: false)
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data.totalGradeText, nil)
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testHideTotalsWhenQuantitativeDataEnabled() {
        mockGetCourseAPI(
            currentGradingPeriodId: "1",
            hideFinalGrade: true,
            multipleGradingPeriodsEnabled: true,
            isRestrict: true
        )

        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(arrangeBy: .groupName, baseOnGradedAssignment: true, gradingPeriodID: "1", ignoreCache: false)
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data.totalGradeText, nil)
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testShowGradeLetter() {
        mockGetCourseAPI(currentGradingPeriodId: "1")
        mockGetEnrollmentsAPI(
            grades: .make(current_grade: "C", current_score: 42)
        )

        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(arrangeBy: .groupName, baseOnGradedAssignment: true, gradingPeriodID: "1", ignoreCache: false)
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data.totalGradeText, "42% (C)")
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }
    func testShowGradeLetterForAllGradingPeriodsNotBasedOnGradedAssignment() {
        mockGetCourseAPI(currentGradingPeriodId: nil)
        mockGetEnrollmentsAPI(
            grades: .make(current_grade: "C", current_score: 42, final_score: 21),
            gradingPeriodID: nil
        )
        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(arrangeBy: .groupName, baseOnGradedAssignment: false, gradingPeriodID: nil, ignoreCache: false)
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data.totalGradeText, "21%")
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testShowGradeLetterForAllGradingPeriodsNotBasedOnGradedAssignmentHasFinalGrade() {
        let finalGrade = "Excellent"
        mockGetCourseAPI(
            currentGradingPeriodId: nil,
            computedFinalGrade: finalGrade
        )
        mockGetEnrollmentsAPI(
            grades: .make(current_grade: "C", current_score: 42, final_score: 21),
            gradingPeriodID: nil
        )

        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(
            arrangeBy: .groupName,
            baseOnGradedAssignment: false,
            gradingPeriodID: nil,
            ignoreCache: false
        ).sink(
            receiveCompletion: { _ in }) { data in
                XCTAssertEqual(data.totalGradeText, "21% (\(finalGrade))")
                expectation.fulfill()
            }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testShowGradeLetterForGradingPeriodNotBasedOnGradedAssignment() {
        mockGetCourseAPI(currentGradingPeriodId: "1")
        mockGetEnrollmentsAPI(
            grades: .make(current_grade: "C", current_score: 42, final_score: 21)
        )

        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(arrangeBy: .groupName, baseOnGradedAssignment: false, gradingPeriodID: "1", ignoreCache: false)
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data.totalGradeText, "21%")
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testShowGradeLetterForAllGradingPeriodsBasedOnGradedAssignmentHasCurrentGrade() {
        let grade = "Excellent"
        mockGetCourseAPI(
            currentGradingPeriodId: nil,
            computedCurrentLetterGrade: grade

        )
        mockGetEnrollmentsAPI(
            grades: .make(current_grade: "C", current_score: 42, final_score: 21),
            gradingPeriodID: nil
        )

        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(
            arrangeBy: .groupName,
            baseOnGradedAssignment: true,
            gradingPeriodID: nil,
            ignoreCache: false
        )
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data.totalGradeText, "42% (\(grade))")
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testShowGradeLetterForAllGradingPeriodsBasedOnGradedAssignmenEmptyCurrentGrade() {
        let grade = "Excellent"
        mockGetCourseAPI(
            currentGradingPeriodId: nil,
            computedCurrentLetterGrade: grade

        )
        mockGetEnrollmentsAPI(
            grades: .make(
                current_grade: "C",
                current_score: 42,
                final_score: 21
            ),
            gradingPeriodID: nil
        )
        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(
            arrangeBy: .groupName,
            baseOnGradedAssignment: true,
            gradingPeriodID: nil,
            ignoreCache: false
        )
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data.totalGradeText, "42% (\(grade))")
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testShowGradeLetterWhenQuantitativeDataEnabled() {
        mockGetCourseAPI(
            currentGradingPeriodId: "1",
            multipleGradingPeriodsEnabled: true,
            isRestrict: true
        )
        mockGetEnrollmentsAPI(grades: .make(current_grade: "C", current_score: 42))

        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(arrangeBy: .groupName, baseOnGradedAssignment: true, gradingPeriodID: "1", ignoreCache: false)
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data.totalGradeText, "C")
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testShowGradeLetterWhenQuantitativeDataEnabledWithBaseOnGradedAssignmentFalse() {
        mockGetCourseAPI(
            currentGradingPeriodId: "1",
            multipleGradingPeriodsEnabled: true,
            isRestrict: true
        )
        mockGetEnrollmentsAPI(grades: .make(final_grade: "C", current_score: 42))

        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(
            arrangeBy: .groupName,
            baseOnGradedAssignment: false,
            gradingPeriodID: "1",
            ignoreCache: false
        )
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data.totalGradeText, "C")
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testShowGradeLetterWhenQuantitativeDataEnabledWithGradingPeriodNil() {
        mockGetCourseAPI(
            currentGradingPeriodId: nil,
            multipleGradingPeriodsEnabled: true,
            computedFinalGrade: "C",
            isRestrict: true
        )
        mockGetEnrollmentsAPI(grades: .make(final_grade: "C", current_score: 42))

        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(
            arrangeBy: .groupName,
            baseOnGradedAssignment: false,
            gradingPeriodID: nil,
            ignoreCache: false
        )
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data.totalGradeText, "C")
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testShowGradeLetterWhenQuantitativeDataEnabledWithGradingPeriodNilHasHaseOnGradedAssignment() {
        mockGetCourseAPI(
            currentGradingPeriodId: nil,
            multipleGradingPeriodsEnabled: true,
            computedCurrentLetterGrade: "C",
            isRestrict: true
        )
        mockGetEnrollmentsAPI(grades: .make(final_grade: "C", current_score: 42))

        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(
            arrangeBy: .groupName,
            baseOnGradedAssignment: true,
            gradingPeriodID: nil,
            ignoreCache: false
        )
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data.totalGradeText, "C")
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testShowGradeLetterWhenQuantitativeDataEnabledWithGradingPeriodWithEmptyGrade() {
        mockGetCourseAPI(
            currentGradingPeriodId: nil,
            multipleGradingPeriodsEnabled: true,
            computedCurrentLetterGrade: "C",
            isRestrict: true
        )
        mockGetEnrollmentsAPI(grades: .make(final_grade: "C", current_score: 42))

        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(
            arrangeBy: .groupName,
            baseOnGradedAssignment: true,
            gradingPeriodID: nil,
            ignoreCache: false
        )
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data.totalGradeText, "C")
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testShowGradeLetterWhenQuantitativeDataEnabledNOGradingPeriodWithEmptyGrade() {
        mockGetCourseAPI(
            currentGradingPeriodId: nil,
            multipleGradingPeriodsEnabled: true,
            totalsForAllGradingPeriodsOption: false,
            isRestrict: true
        )
        mockGetEnrollmentsAPI(grades: .make(current_score: 42))
        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(
            arrangeBy: .groupName,
            baseOnGradedAssignment: true,
            gradingPeriodID: nil,
            ignoreCache: false
        )
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertNil(data.totalGradeText)
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testShowGradeLetterWhenQuantitativeDataEnabledWithGradingPeriodWithGradingScheme() {
        mockGetCourseAPI(currentGradingPeriodId: "1", isRestrict: true)
        mockGetEnrollmentsAPI(grades: .make(current_score: 42))

        let testee = GradeListInteractorLive(courseID: "1", userID: currentSession.userID, env: environment)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.getGrades(
            arrangeBy: .groupName,
            baseOnGradedAssignment: true,
            gradingPeriodID: "1",
            ignoreCache: false
        )
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data.totalGradeText, "N/A")
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    private func mockGetCourseAPI(
        currentGradingPeriodId: String?,
        computedCurrentGrade: String? = nil,
        hideFinalGrade: Bool = false,
        multipleGradingPeriodsEnabled: Bool = false,
        totalsForAllGradingPeriodsOption: Bool = true,
        computedCurrentLetterGrade: String? = nil,
        computedFinalGrade: String? = nil,
        isRestrict: Bool = false
    ) {
        api.mock(
            GetCourse(courseID: "1"),
            value: .make(
                enrollments: [
                    .make(
                        id: nil,
                        course_id: "1",
                        enrollment_state: .active,
                        user_id: currentSession.userID,
                        computed_current_grade: computedCurrentGrade,
                        computed_current_letter_grade: computedCurrentLetterGrade,
                        computed_final_grade: computedFinalGrade,
                        multiple_grading_periods_enabled: multipleGradingPeriodsEnabled,
                        totals_for_all_grading_periods_option: totalsForAllGradingPeriodsOption,
                        current_grading_period_id: currentGradingPeriodId
                    )
                ],
                hide_final_grades: hideFinalGrade,
                settings: .make(restrict_quantitative_data: isRestrict)
            )
        )
    }

    private func mockGetEnrollmentsAPI(grades: APIEnrollment.Grades, gradingPeriodID: String? = "1") {
        api.mock(
            GetEnrollments(
                context: .course("1"),
                userID: currentSession.userID,
                gradingPeriodID: gradingPeriodID,
                types: ["StudentEnrollment"],
                states: [.active, .completed]
            ),
            value: [
                .make(
                    id: "1",
                    course_id: "1",
                    enrollment_state: .active,
                    type: "StudentEnrollment",
                    user_id: currentSession.userID,
                    grades: grades
                )
            ]
        )
    }
}
