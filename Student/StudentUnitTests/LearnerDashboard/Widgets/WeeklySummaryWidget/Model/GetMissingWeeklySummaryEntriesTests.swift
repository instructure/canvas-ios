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

@testable import Core
import XCTest
@testable import Student

final class GetMissingWeeklySummaryEntriesTests: StudentTestCase {

    private var testee: GetMissingWeeklySummaryEntries!

    override func setUp() {
        super.setUp()
        testee = GetMissingWeeklySummaryEntries()
    }

    // MARK: - write

    func test_write_createsEntryForEachAssignment() {
        let response = GetMissingWeeklySummaryEntries.Response(
            missing: [
                .make(id: "a1", name: "Essay"),
                .make(id: "a2", name: "Quiz")
            ],
            assignmentGroupsByCourse: [:]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertEqual(entries.count, 2)
        XCTAssertTrue(entries.contains(where: { $0.title == "Essay" }))
        XCTAssertTrue(entries.contains(where: { $0.title == "Quiz" }))
    }

    func test_write_setsWeekStartToMissingWeekStart() {
        let response = GetMissingWeeklySummaryEntries.Response(
            missing: [.make(id: "a1")],
            assignmentGroupsByCourse: [:]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertEqual(entries.first?.weekStart, CDDashboardWeeklySummaryEntry.missingWeekStart)
    }

    func test_write_setsCategoryToMissing() {
        let response = GetMissingWeeklySummaryEntries.Response(
            missing: [.make(id: "a1")],
            assignmentGroupsByCourse: [:]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertEqual(entries.first?.category, .missing)
    }

    func test_write_setsAssignmentWeightWhenGroupWeightsApply() {
        let assignment = APIAssignment.make(
            course_id: "c1",
            id: "a1",
            points_possible: 100,
            submission: .make(submitted_at: nil, workflow_state: .unsubmitted)
        )
        let group = APIAssignmentGroup.make(
            group_weight: 40,
            assignments: [assignment]
        )
        let response = GetMissingWeeklySummaryEntries.Response(
            missing: [assignment],
            assignmentGroupsByCourse: ["c1": [group]]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertNotNil(entries.first?.gradeWeight)
    }

    func test_write_setsNilAssignmentWeightWhenGroupWeightIsZero() {
        let assignment = APIAssignment.make(course_id: "c1", id: "a1", points_possible: 100)
        let group = APIAssignmentGroup.make(group_weight: 0, assignments: [assignment])
        let response = GetMissingWeeklySummaryEntries.Response(
            missing: [assignment],
            assignmentGroupsByCourse: ["c1": [group]]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertNil(entries.first?.gradeWeight)
    }

    func test_write_setsNilAssignmentWeightWhenNoMatchingGroup() {
        let assignment = APIAssignment.make(course_id: "c1", id: "a1", points_possible: 100)
        let response = GetMissingWeeklySummaryEntries.Response(
            missing: [assignment],
            assignmentGroupsByCourse: [:]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertNil(entries.first?.gradeWeight)
    }

    func test_write_setsNilAssignmentWeightWhenOmitFromFinalGrade() {
        let assignment = APIAssignment.make(course_id: "c1", id: "a1", points_possible: 100, omit_from_final_grade: true)
        let group = APIAssignmentGroup.make(group_weight: 40, assignments: [assignment])
        let response = GetMissingWeeklySummaryEntries.Response(
            missing: [assignment],
            assignmentGroupsByCourse: ["c1": [group]]
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertNil(entries.first?.gradeWeight)
    }

    func test_write_doesNothingWhenResponseIsNil() {
        testee.write(response: nil, urlResponse: nil, to: databaseClient)

        let entries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertTrue(entries.isEmpty)
    }

    // MARK: - makeRequest

    func test_makeRequest_callsCompletionWithMissingAssignments() {
        let assignment = APIAssignment.make(course_id: "c1", id: "a1", name: "Late Essay")
        api.mock(GetMissingSubmissionsRequest(includes: [.planner_overrides, .course])) { _ in
            ([assignment], nil, nil)
        }
        api.mock(GetAssignmentGroupsRequest(courseID: "c1", include: [.assignments, .submission], perPage: 100)) { _ in
            ([] as [APIAssignmentGroup], nil, nil)
        }

        let completionExpectation = expectation(description: "completion")
        var capturedResponse: GetMissingWeeklySummaryEntries.Response?
        testee.makeRequest(environment: env) { response, _, _ in
            capturedResponse = response
            completionExpectation.fulfill()
        }
        waitForExpectations(timeout: 5)

        XCTAssertEqual(capturedResponse?.missing.count, 1)
        XCTAssertEqual(capturedResponse?.missing.first?.id.rawValue, "a1")
    }

    func test_makeRequest_callsCompletionWithEmptyResponseWhenNoMissingAssignments() {
        api.mock(GetMissingSubmissionsRequest(includes: [.planner_overrides, .course])) { _ in
            ([] as [APIAssignment], nil, nil)
        }

        let completionExpectation = expectation(description: "completion")
        var capturedResponse: GetMissingWeeklySummaryEntries.Response?
        testee.makeRequest(environment: env) { response, _, _ in
            capturedResponse = response
            completionExpectation.fulfill()
        }
        waitForExpectations(timeout: 5)

        XCTAssertTrue(capturedResponse?.missing.isEmpty == true)
        XCTAssertTrue(capturedResponse?.assignmentGroupsByCourse.isEmpty == true)
    }

    // MARK: - cacheKey

    func test_cacheKey_hasExpectedValue() {
        XCTAssertEqual(testee.cacheKey, GetMissingWeeklySummaryEntries.cacheKey)
    }

    // MARK: - reset

    func test_reset_deletesOnlyMissingEntries() {
        let missingEntry = CDDashboardWeeklySummaryEntry.findOrCreate(weekStart: CDDashboardWeeklySummaryEntry.missingWeekStart, category: .missing, id: "m1", in: databaseClient)
        missingEntry.weekStart = CDDashboardWeeklySummaryEntry.missingWeekStart
        missingEntry.category = .missing
        let dueEntry = CDDashboardWeeklySummaryEntry.findOrCreate(weekStart: .distantPast, category: .due, id: "d1", in: databaseClient)
        dueEntry.weekStart = .distantPast
        dueEntry.category = .due

        testee.reset(context: databaseClient)

        let missingEntries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertTrue(missingEntries.isEmpty)
        let allEntries: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(allEntries.count, 1)
        XCTAssertEqual(allEntries.first?.category, .due)
    }
}
