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

final class GetWeeklyDueAndGradesEntriesTests: StudentTestCase {

    private var weekStart: Date!
    private var testee: GetWeeklyDueAndGradesEntries!

    override func setUp() {
        super.setUp()
        weekStart = Clock.now.startOfWeek()
        testee = GetWeeklyDueAndGradesEntries(weekStart: weekStart, studentId: "student1")
    }

    // MARK: - write — due entries

    func test_write_createsDueEntryForEachPlannable() {
        let date = weekStart.addDays(2)
        let response = GetWeeklyDueAndGradesEntries.Response(
            due: [
                .make(course_id: "c1", plannable_id: "p1", plannable: .make(title: "Essay"), plannable_date: date),
                .make(course_id: "c1", plannable_id: "p2", plannable: .make(title: "Quiz"), plannable_date: date)
            ],
            grades: [],
            assignmentGroupsByCourse: ["c1": [.make(assignments: [.make(id: "p1"), .make(id: "p2")])]]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        let dueEntries = entries.filter { $0.category == .due }
        XCTAssertEqual(dueEntries.count, 2)
        XCTAssertTrue(dueEntries.contains(where: { $0.title == "Essay" }))
        XCTAssertTrue(dueEntries.contains(where: { $0.title == "Quiz" }))
    }

    func test_write_setsDueEntryWeekStart() {
        let date = weekStart.addDays(1)
        let response = GetWeeklyDueAndGradesEntries.Response(
            due: [.make(course_id: "c1", plannable_id: "p1", plannable_date: date)],
            grades: [],
            assignmentGroupsByCourse: ["c1": [.make(assignments: [.make(id: "p1")])]]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        let dueEntry = entries.first { $0.category == .due }
        XCTAssertEqual(dueEntry?.weekStart, weekStart)
    }

    // MARK: - write — grade entries

    func test_write_createsGradeEntryForSubmissionWithinWeek() {
        let gradedAt = weekStart.addDays(3)
        let response = GetWeeklyDueAndGradesEntries.Response(
            due: [],
            grades: [makeCourseNode(courseId: "c1", submissionId: "s1", gradedAt: gradedAt)],
            assignmentGroupsByCourse: [:]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        let gradeEntries = entries.filter { $0.category == .newGrades }
        XCTAssertEqual(gradeEntries.count, 1)
    }

    func test_write_skipsGradeEntryWhenGradedAtIsAtOrAfterWeekEnd() {
        let weekEnd = weekStart.endOfWeek()
        let response = GetWeeklyDueAndGradesEntries.Response(
            due: [],
            grades: [makeCourseNode(courseId: "c1", submissionId: "s1", gradedAt: weekEnd)],
            assignmentGroupsByCourse: [:]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertTrue(entries.filter { $0.category == .newGrades }.isEmpty)
    }

    func test_write_skipsGradeEntryWhenGradedAtIsNil() {
        let response = GetWeeklyDueAndGradesEntries.Response(
            due: [],
            grades: [makeCourseNode(courseId: "c1", submissionId: "s1", gradedAt: nil)],
            assignmentGroupsByCourse: [:]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertTrue(entries.filter { $0.category == .newGrades }.isEmpty)
    }

    func test_write_skipsGradeEntryWhenGradeHidden() {
        let gradedAt = weekStart.addDays(2)
        let response = GetWeeklyDueAndGradesEntries.Response(
            due: [],
            grades: [makeCourseNode(courseId: "c1", submissionId: "s1", gradedAt: gradedAt, gradeHidden: true)],
            assignmentGroupsByCourse: [:]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertTrue(entries.filter { $0.category == .newGrades }.isEmpty)
    }

    func test_write_setsGradeEntryWeekStart() {
        let gradedAt = weekStart.addDays(1)
        let response = GetWeeklyDueAndGradesEntries.Response(
            due: [],
            grades: [makeCourseNode(courseId: "c1", submissionId: "s1", gradedAt: gradedAt)],
            assignmentGroupsByCourse: [:]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        let gradeEntry = entries.first { $0.category == .newGrades }
        XCTAssertEqual(gradeEntry?.weekStart, weekStart)
    }

    // MARK: - reset

    func test_reset_deletesEntriesForThisWeekOnly() {
        let otherWeekStart = weekStart.addDays(7)
        let thisEntry = CDDashboardWeeklySummaryEntry.findOrCreate(weekStart: weekStart, category: .due, id: "e1", in: databaseClient)
        thisEntry.weekStart = weekStart
        thisEntry.category = .due
        let otherEntry = CDDashboardWeeklySummaryEntry.findOrCreate(weekStart: otherWeekStart, category: .due, id: "e2", in: databaseClient)
        otherEntry.weekStart = otherWeekStart
        otherEntry.category = .due

        testee.reset(context: databaseClient)

        let remainingForThisWeek: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertTrue(remainingForThisWeek.isEmpty)
        let all: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.weekStart, otherWeekStart)
    }

    func test_write_skipsGradeEntryWhenGradedAtIsBeforeWeekStart() {
        let gradedAt = weekStart.addDays(-1)
        let response = GetWeeklyDueAndGradesEntries.Response(
            due: [],
            grades: [makeCourseNode(courseId: "c1", submissionId: "s1", gradedAt: gradedAt)],
            assignmentGroupsByCourse: [:]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertTrue(entries.filter { $0.category == .newGrades }.isEmpty)
    }

    func test_write_skipsDueEntryWhenNotFoundInAssignmentGroups() {
        let date = weekStart.addDays(1)
        let response = GetWeeklyDueAndGradesEntries.Response(
            due: [.make(course_id: "c1", plannable_id: "p1", plannable_date: date)],
            grades: [],
            assignmentGroupsByCourse: ["c2": [.make(assignments: [.make(id: "other")])]]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertTrue(entries.filter { $0.category == .due }.isEmpty)
    }

    func test_write_setsAssignmentWeightForDueEntry() {
        let date = weekStart.addDays(2)
        let group = APIAssignmentGroup.make(group_weight: 40, assignments: [.make(id: "p1", points_possible: 100)])
        let response = GetWeeklyDueAndGradesEntries.Response(
            due: [.make(course_id: "c1", plannable_id: "p1", plannable_date: date)],
            grades: [],
            assignmentGroupsByCourse: ["c1": [group]]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertNotNil(entries.first { $0.category == .due }?.gradeWeight)
    }

    func test_write_doesNothingWhenResponseIsNil() {
        testee.write(response: nil, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertTrue(entries.isEmpty)
    }

    func test_write_createsMultipleGradeEntriesFromEdgesInOneCourseNode() {
        let gradedAt = weekStart.addDays(1)
        let assignmentNode1 = GetRecentGradedSubmissionsRequest.Response.AssignmentNode(
            _id: "a1", name: "Exam 1", htmlUrl: nil, pointsPossible: 100, gradingType: "points"
        )
        let assignmentNode2 = GetRecentGradedSubmissionsRequest.Response.AssignmentNode(
            _id: "a2", name: "Exam 2", htmlUrl: nil, pointsPossible: 100, gradingType: "points"
        )
        let edge1 = GetRecentGradedSubmissionsRequest.Response.Edge(node: .init(
            _id: "s1", score: 80, grade: "B", excused: false, gradeHidden: false, gradedAt: gradedAt, assignment: assignmentNode1
        ))
        let edge2 = GetRecentGradedSubmissionsRequest.Response.Edge(node: .init(
            _id: "s2", score: 90, grade: "A", excused: false, gradeHidden: false, gradedAt: gradedAt, assignment: assignmentNode2
        ))
        let courseNode = GetRecentGradedSubmissionsRequest.Response.CourseNode(
            _id: "c1", name: "Course c1", submissions: .init(edges: [edge1, edge2])
        )
        let response = GetWeeklyDueAndGradesEntries.Response(due: [], grades: [courseNode], assignmentGroupsByCourse: [:])

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let gradeEntries = (databaseClient.fetch(scope: testee.scope) as [CDDashboardWeeklySummaryEntry]).filter { $0.category == .newGrades }
        XCTAssertEqual(gradeEntries.count, 2)
    }

    func test_write_createsGradeEntriesFromMultipleCourseNodes() {
        let gradedAt = weekStart.addDays(2)
        let response = GetWeeklyDueAndGradesEntries.Response(
            due: [],
            grades: [
                makeCourseNode(courseId: "c1", submissionId: "s1", assignmentId: "a1", gradedAt: gradedAt),
                makeCourseNode(courseId: "c2", submissionId: "s2", assignmentId: "a2", gradedAt: gradedAt)
            ],
            assignmentGroupsByCourse: [:]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let gradeEntries = (databaseClient.fetch(scope: testee.scope) as [CDDashboardWeeklySummaryEntry]).filter { $0.category == .newGrades }
        XCTAssertEqual(gradeEntries.count, 2)
        XCTAssertTrue(gradeEntries.contains(where: { $0.courseId == "c1" }))
        XCTAssertTrue(gradeEntries.contains(where: { $0.courseId == "c2" }))
    }

    func test_write_lookupsCourseRestrictQuantitativeDataForGradeEntry() {
        Course.make(from: .make(id: "c1", settings: .make(restrict_quantitative_data: true)), in: databaseClient)
        let gradedAt = weekStart.addDays(1)
        let response = GetWeeklyDueAndGradesEntries.Response(
            due: [],
            grades: [makeCourseNode(courseId: "c1", submissionId: "s1", gradedAt: gradedAt)],
            assignmentGroupsByCourse: [:]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertTrue(entries.first { $0.category == .newGrades }?.restrictQuantitativeData == true)
    }

    func test_write_setsNilAssignmentWeightForDueEntryWhenGroupWeightIsZero() {
        let date = weekStart.addDays(1)
        let group = APIAssignmentGroup.make(group_weight: 0, assignments: [.make(id: "p1", points_possible: 100)])
        let response = GetWeeklyDueAndGradesEntries.Response(
            due: [.make(course_id: "c1", plannable_id: "p1", plannable_date: date)],
            grades: [],
            assignmentGroupsByCourse: ["c1": [group]]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertNil(entries.first { $0.category == .due }?.gradeWeight)
    }

    // MARK: - scope ordering

    func test_scope_ordersDueEntriesByDateThenAssignmentId() {
        let date1 = weekStart.addDays(1)
        let date2 = weekStart.addDays(2)
        let group = APIAssignmentGroup.make(assignments: [.make(id: "p1"), .make(id: "p2"), .make(id: "p3")])
        let response = GetWeeklyDueAndGradesEntries.Response(
            due: [
                .make(course_id: "c1", plannable_id: "p3", plannable_date: date2),
                .make(course_id: "c1", plannable_id: "p1", plannable_date: date1),
                .make(course_id: "c1", plannable_id: "p2", plannable_date: date1)
            ],
            grades: [],
            assignmentGroupsByCourse: ["c1": [group]]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertEqual(entries.map { $0.assignmentId }, ["p1", "p2", "p3"])
    }

    // MARK: - cacheKey

    func test_cacheKey_containsWeekStartIsoString() {
        XCTAssertEqual(testee.cacheKey, "\(GetWeeklyDueAndGradesEntries.cacheKeyPrefix)\(weekStart.isoString())")
    }

    // MARK: - Private helpers

    private func makeCourseNode(
        courseId: String,
        submissionId: String,
        assignmentId: String = "assignment1",
        gradedAt: Date?,
        gradeHidden: Bool = false
    ) -> GetRecentGradedSubmissionsRequest.Response.CourseNode {
        let assignment = GetRecentGradedSubmissionsRequest.Response.AssignmentNode(
            _id: assignmentId,
            name: "Final Exam",
            htmlUrl: nil,
            pointsPossible: 100,
            gradingType: "points"
        )
        let submissionNode = GetRecentGradedSubmissionsRequest.Response.SubmissionNode(
            _id: submissionId,
            score: 80,
            grade: "B",
            excused: false,
            gradeHidden: gradeHidden,
            gradedAt: gradedAt,
            assignment: assignment
        )
        let edge = GetRecentGradedSubmissionsRequest.Response.Edge(node: submissionNode)
        let submissions = GetRecentGradedSubmissionsRequest.Response.SubmissionsConnection(edges: [edge])
        return GetRecentGradedSubmissionsRequest.Response.CourseNode(
            _id: courseId,
            name: "Course \(courseId)",
            submissions: submissions
        )
    }
}
