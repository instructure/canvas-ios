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
@testable import Core
import TestsFoundation
import CoreData

class GradesTests: CoreTestCase {
    var courseID = "1"
    var userID = "1"

    func testGradesInCurrentGradingPeriod() {
        api.mock(
            GetCourseRequest(courseID: courseID),
            value: .make(
                id: ID(courseID),
                enrollments: [
                    .make(
                        id: nil,
                        enrollment_state: .active,
                        type: "student",
                        user_id: userID,
                        computed_current_score: 100,
                        multiple_grading_periods_enabled: true,
                        current_grading_period_id: "1",
                        current_period_computed_current_score: 50
                    ),
                ]
            )
        )
        api.mock(
            GetEnrollmentsRequest(context: ContextModel(.course, id: courseID), userID: userID, gradingPeriodID: "1"),
            value: [
                .make(
                    id: "1",
                    enrollment_state: .active,
                    type: "StudentEnrollment",
                    user_id: userID,
                    grades: APIEnrollment.Grades(
                        html_url: "/grades",
                        current_grade: nil,
                        final_grade: nil,
                        current_score: 50,
                        final_score: nil
                    ),
                    multiple_grading_periods_enabled: nil
                ),
            ]
        )
        api.mock(
            GetAssignmentGroupsRequest(courseID: courseID, gradingPeriodID: "1", include: [.assignments]),
            value: [.make(id: "1", assignments: [.make(id: "1", submission: nil)])]
        )
        api.mock(
            GetAssignmentsRequest(courseID: courseID, orderBy: .position, include: [.observed_users, .submission], perPage: 99),
            value: [.make(id: "1", submission: .make(), assignment_group_id: "1")]
        )
        api.mock(GetGradingPeriodsRequest(courseID: courseID), value: [.make(id: "1", title: "Period 2"), .make(id: "2", title: "Period 1")])
        let grades = Grades(courseID: courseID, userID: userID)
        grades.refresh()
        XCTAssertEqual(grades.assignments.count, 1)
        let assignment = grades.assignments.first
        XCTAssertEqual(assignment?.id, "1")
        XCTAssertEqual(assignment?.gradingPeriodID, "1")
        XCTAssertEqual(assignment?.assignmentGroup?.id, "1")
        XCTAssertNotNil(assignment?.submission)
        XCTAssertEqual(grades.enrollment?.currentScore, 50)
        XCTAssertEqual(grades.enrollment?.multipleGradingPeriodsEnabled, true)
        XCTAssertEqual(grades.gradingPeriods.count, 2)
        XCTAssertEqual(grades.gradingPeriods[0]?.title, "Period 1")
        XCTAssertEqual(grades.gradingPeriods[1]?.title, "Period 2")
    }

    func testNoGradingPeriods() throws {
        api.mock(
            GetCourseRequest(courseID: courseID),
            value: .make(id: ID(courseID), enrollments: [
                .make(
                    id: nil,
                    enrollment_state: .active,
                    type: "student",
                    user_id: userID,
                    computed_current_score: 100,
                    multiple_grading_periods_enabled: false,
                    current_grading_period_id: nil,
                    current_period_computed_current_score: nil
                ),
            ])
        )
        api.mock(
            GetEnrollmentsRequest(context: ContextModel(.course, id: courseID), userID: userID, gradingPeriodID: nil),
            value: [
                .make(
                    id: "1",
                    enrollment_state: .active,
                    type: "StudentEnrollment",
                    user_id: userID,
                    grades: APIEnrollment.Grades(
                        html_url: "/grades",
                        current_grade: nil,
                        final_grade: nil,
                        current_score: 100,
                        final_score: nil
                    ),
                    multiple_grading_periods_enabled: nil
                ),
            ]
        )
        api.mock(
            GetAssignmentGroupsRequest(courseID: courseID, gradingPeriodID: nil, include: [.assignments]),
            value: [.make(id: "1", assignments: [.make(id: "1")])]
        )
        api.mock(
            GetAssignmentsRequest(courseID: courseID, orderBy: .position, include: [.observed_users, .submission], perPage: 99),
            value: [.make(id: "1", assignment_group_id: "1")]
        )
        let grades = Grades(courseID: courseID, userID: userID)
        grades.refresh()
        XCTAssertEqual(grades.assignments.count, 1)
        let assignment = grades.assignments.first
        XCTAssertEqual(assignment?.id, "1")
        XCTAssertEqual(assignment?.gradingPeriodID, nil)
        XCTAssertEqual(assignment?.assignmentGroup?.id, "1")
        XCTAssertEqual(grades.enrollment?.currentScore, 100)
    }

    func testChangeGradingPeriod() {
        api.mock(
            GetCourseRequest(courseID: courseID),
            value: .make(id: ID(courseID), enrollments: [
                .make(
                    id: nil,
                    enrollment_state: .active,
                    type: "student",
                    user_id: userID,
                    computed_current_score: 100,
                    multiple_grading_periods_enabled: true,
                    current_grading_period_id: "1",
                    current_period_computed_current_score: 50
                ),
            ])
        )
        api.mock(
            GetEnrollmentsRequest(context: ContextModel(.course, id: courseID), userID: userID, gradingPeriodID: "1"),
            value: [
                .make(
                    id: "1",
                    enrollment_state: .active,
                    type: "StudentEnrollment",
                    user_id: userID,
                    grades: APIEnrollment.Grades(
                        html_url: "/grades",
                        current_grade: nil,
                        final_grade: nil,
                        current_score: 10,
                        final_score: nil
                    )
                ),
            ]
        )
        api.mock(
            GetEnrollmentsRequest(context: ContextModel(.course, id: courseID), userID: userID, gradingPeriodID: "2"),
            value: [
                .make(
                    id: "1",
                    enrollment_state: .active,
                    type: "StudentEnrollment",
                    user_id: userID,
                    grades: APIEnrollment.Grades(
                        html_url: "/grades",
                        current_grade: nil,
                        final_grade: nil,
                        current_score: 20,
                        final_score: nil
                    )
                ),
            ]
        )
        api.mock(
            GetAssignmentGroupsRequest(courseID: courseID, gradingPeriodID: "1", include: [.assignments]),
            value: [.make(id: "1"), .make(id: "2")]
        )
        api.mock(
            GetAssignmentGroupsRequest(courseID: courseID, gradingPeriodID: "2", include: [.assignments]),
            value: [.make(id: "1", assignments: [.make(id: "1", submission: nil)]), .make(id: "2", assignments: [.make(id: "2", submission: nil)])]
        )
        api.mock(
            GetAssignmentsRequest(courseID: courseID, orderBy: .position, include: [.observed_users, .submission], perPage: 99),
            value: [.make(id: "1", assignment_group_id: "1")]
        )
        api.mock(
            GetAssignmentsRequest(courseID: courseID, orderBy: .position, include: [.observed_users, .submission], perPage: 99),
            value: [.make(id: "2", assignment_group_id: "2")]
        )
        let grades = Grades(courseID: courseID, userID: userID)
        grades.refresh()
        grades.gradingPeriodID = "2"
        XCTAssertEqual(grades.assignments.count, 1)
        let assignment = grades.assignments.first
        XCTAssertEqual(assignment?.id, "2")
        XCTAssertEqual(assignment?.gradingPeriodID, "2")
        XCTAssertEqual(assignment?.assignmentGroup?.id, "2")
        XCTAssertNotNil(assignment?.submission)
        XCTAssertEqual(grades.enrollment?.currentScore(gradingPeriodID: "2"), 20)
    }

    func testDoesNotDeleteAssignmentsInOtherCaches() {
        let thisCache = Assignment.make(from: .make(id: "1", course_id: ID(courseID)), cacheKey: "grades")
        let otherCache = Assignment.make(from: .make(id: "1", course_id: ID(courseID)), cacheKey: "other")
        api.mock(GetCourseRequest(courseID: courseID), value: .make(id: ID(courseID), enrollments: [.make(user_id: userID, current_grading_period_id: nil)]))
        api.mock(GetEnrollmentsRequest(context: ContextModel(.course, id: courseID), userID: userID, gradingPeriodID: nil), value: [.make()])
        api.mock(GetAssignmentGroupsRequest(courseID: courseID, gradingPeriodID: nil, include: [.assignments]), value: [])
        api.mock(GetAssignmentsRequest(courseID: courseID, orderBy: .position, include: [.observed_users, .submission], perPage: 99), value: [])
        let grades = Grades(courseID: courseID, userID: userID)
        grades.refresh()
        XCTAssertTrue(databaseClient.isObjectDeleted(thisCache))
        XCTAssertFalse(databaseClient.isObjectDeleted(otherCache))
    }
}
