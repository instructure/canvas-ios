//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class GetSubmissionsTests: CoreTestCase {
    func testItCreatesSubmission() {
        let context = Context(.course, id: "1")
        let apiSubmission = APISubmission.make(
            assignment_id: "2",
            user_id: "3"
        )

        let getSubmission = GetSubmission(context: context, assignmentID: "2", userID: "3")
        getSubmission.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)
        let submission = submissions.first!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
    }

    func testItCreatesSubmissionHistory() {
        let context = Context(.course, id: "1")
        let apiSubmission = APISubmission.make(
            assignment_id: "2",
            attempt: 2,
            submission_history: [
                APISubmission.make(assignment_id: "2", attempt: 2, user_id: "3"),
                APISubmission.make(assignment_id: "2", attempt: 1, user_id: "3")
            ],
            user_id: "3"
        )
        let getSubmission = GetSubmission(context: context, assignmentID: "2", userID: "3")
        getSubmission.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 2)
        let submission = submissions.first!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
    }

    func testNoHistoryDoesntDelete() {
        let context = Context(.course, id: "1")
        Submission.make(from: .make(assignment_id: "2", attempt: 2, late: false, user_id: "3"))
        Submission.make(from: .make(assignment_id: "2", attempt: 1, user_id: "3"))
        let apiSubmission = APISubmission.make(
            assignment_id: "2",
            attempt: 2,
            late: true,
            user_id: "3"
        )

        let getSubmission = GetSubmission(context: context, assignmentID: "2", userID: "3")
        getSubmission.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 2)
        let submission = submissions.first(where: { $0.attempt == 2 })!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
        XCTAssertEqual(submission.late, true)
    }

    func testCacheKey() {
        let getSubmission = GetSubmission(context: .course("1"), assignmentID: "2", userID: "3")
        XCTAssertEqual(getSubmission.cacheKey, "get-1-2-3-submission")
    }

    func testRequest() {
        let getSubmission = GetSubmission(context: .course("1"), assignmentID: "2", userID: "3")
        XCTAssertEqual(getSubmission.request.path, "courses/1/assignments/2/submissions/3")
    }

    func testScope() {
        let getSubmission = GetSubmission(context: .course("1"), assignmentID: "2", userID: "3")
        let scope = Scope(
            predicate: NSPredicate(
                format: "%K == %@ AND %K == %@",
                #keyPath(Submission.assignmentID),
                "2",
                #keyPath(Submission.userID),
                "3"
            ),
            order: [NSSortDescriptor(key: #keyPath(Submission.attempt), ascending: false)]
        )
        XCTAssertEqual(getSubmission.scope, scope)
    }

    func testGetSubmissions() {
        let useCase = GetSubmissions(context: .course("1"), assignmentID: "1")
        XCTAssertEqual(useCase.cacheKey, "courses/1/assignments/1/submissions")
        XCTAssertEqual(useCase.request.assignmentID, "1")
        XCTAssertEqual(useCase.scope.order, [
            NSSortDescriptor(key: #keyPath(Submission.user.sortableName), naturally: true),
            NSSortDescriptor(key: #keyPath(Submission.sortableName), naturally: true),
            NSSortDescriptor(key: #keyPath(Submission.userID), naturally: true)
        ])
        useCase.shuffled = true
        XCTAssertEqual(useCase.scope.order, [NSSortDescriptor(key: #keyPath(Submission.shuffleOrder), ascending: true)])
        XCTAssertEqual(useCase.scope.predicate, NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(Submission.assignmentID), equals: "1"),
            NSPredicate(key: #keyPath(Submission.isLatest), equals: true),
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "%K.@count == 0", #keyPath(Submission.enrollments)),
                NSPredicate(format: "NONE %K IN %@", #keyPath(Submission.enrollments.stateRaw), ["inactive", "invited"]),
                NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "ANY %K IN %@", #keyPath(Submission.enrollments.stateRaw), ["active"]),
                    NSPredicate(format: "ANY %K != nil", #keyPath(Submission.enrollments.courseSectionID))
                ])
            ])
        ]))

        useCase.filter = [.late]
        XCTAssertEqual(useCase.scope.predicate, NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(Submission.assignmentID), equals: "1"),
            NSPredicate(key: #keyPath(Submission.isLatest), equals: true),
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "%K.@count == 0", #keyPath(Submission.enrollments)),
                NSPredicate(format: "NONE %K IN %@", #keyPath(Submission.enrollments.stateRaw), ["inactive", "invited"]),
                NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "ANY %K IN %@", #keyPath(Submission.enrollments.stateRaw), ["active"]),
                    NSPredicate(format: "ANY %K != nil", #keyPath(Submission.enrollments.courseSectionID))
                ])
            ]),
            NSPredicate(key: #keyPath(Submission.late), equals: true)
        ]))
    }

    func testGetSubmissionsFilterRawValue() {
        typealias Status = GetSubmissions.Filter.Status
        XCTAssertEqual(Status(rawValue: "bogus"), nil)
        XCTAssertEqual(Status(rawValue: "late"), .late)
        XCTAssertEqual(Status.late.rawValue, "late")
        XCTAssertEqual(Status(rawValue: "not_submitted"), .notSubmitted)
        XCTAssertEqual(Status.notSubmitted.rawValue, "not_submitted")
        XCTAssertEqual(Status(rawValue: "submitted"), .submitted)
        XCTAssertEqual(Status.submitted.rawValue, "submitted")
        XCTAssertEqual(Status(rawValue: "graded"), .graded)
        XCTAssertEqual(Status.graded.rawValue, "graded")
    }

    func testGetSubmissionsFilterPredicate() {
        typealias Filter = GetSubmissions.Filter
        XCTAssertEqual(Filter.Status.late.predicate, NSPredicate(key: #keyPath(Submission.late), equals: true))
        XCTAssertEqual(
            Filter.Status.notSubmitted.predicate,
            NSCompoundPredicate(type: .or, subpredicates: [
                NSPredicate(
                    format: "workflowStateRaw == 'unsubmitted' AND (excusedRaw == nil OR excusedRaw != true) AND customGradeStatusId == nil"
                ),
                NSPredicate(
                    format: "workflowStateRaw == 'graded' AND submittedAt == nil AND scoreRaw == nil"
                )
            ])
        )
        XCTAssertEqual(Filter.status(.graded).predicate, NSPredicate(format: "%K == true OR %K != nil OR (%K != nil AND %K == 'graded')",
            #keyPath(Submission.excusedRaw),
            #keyPath(Submission.customGradeStatusId),
            #keyPath(Submission.scoreRaw),
            #keyPath(Submission.workflowStateRaw)
        ))
        XCTAssertEqual(Filter.scoreMoreThan(100).predicate, NSPredicate(format: "%K > %@", #keyPath(Submission.scoreRaw), NSNumber(value: 100.0)))
        XCTAssertEqual(Filter.scoreLessThan(0).predicate, NSPredicate(format: "%K < %@", #keyPath(Submission.scoreRaw), NSNumber(value: 0.0)))
        XCTAssertEqual(Filter.section("1", "c").predicate, NSPredicate(format: "ANY %K IN %@", #keyPath(Submission.enrollments.courseSectionID), [ "1", "c" ]))
    }

    func testGetSubmissionsFilterName() {
        typealias Filter = GetSubmissions.Filter
        User.make(from: .make(short_name: "Me"))
        CourseSection.make(from: .make(id: "1", name: "One"))
        CourseSection.make(from: .make(id: "2", name: "Two"))
        Enrollment.make(from: .make(id: "1", course_id: "1", user_id: "1"))
        Enrollment.make(from: .make(id: "2", course_id: "1", user_id: "2"))
        Submission.make(from: .make(assignment: .make(), id: "1", user_id: "1"))
        Submission.make(from: .make(id: "2", user_id: "2"))

        XCTAssertEqual(Filter.Status.late.name, "Late")
        XCTAssertEqual(Filter.Status.notSubmitted.name, "Not Submitted")
        XCTAssertEqual(Filter.Status.submitted.name, "Submitted")
        XCTAssertEqual(Filter.Status.graded.name, "Graded")

        XCTAssertEqual(Filter.Score.moreThan(100).name, "Scored More than 100")
        XCTAssertEqual(Filter.Score.lessThan(0).name, "Scored Less than 0")
    }

    func testGroupSubmissionWithIndividualGradesOrder() {
        let date = Date()
        let group = APISubmission.Group(id: nil, name: "Group 1")
        Submission.save([
            APISubmission.make(group: group, id: "1", submission_history: [], submitted_at: date, user: .make(id: "B2", sortable_name: "B"), user_id: "B2"),
            APISubmission.make(group: group, id: "2", submission_history: [], submitted_at: date, user: .make(id: "B1", sortable_name: "B"), user_id: "B1"),
            APISubmission.make(group: group, id: "3", submission_history: [], submitted_at: date, user: .make(id: "C", sortable_name: "C"), user_id: "C"),
            APISubmission.make(group: group, id: "4", submission_history: [], submitted_at: date, user: .make(id: "A", sortable_name: "A"), user_id: "A")
        ], in: databaseClient)

        let testee = GetSubmissions(context: .course("1"), assignmentID: "1")
        let fetchedSubmissions: [Submission] = databaseClient.fetch(scope: testee.scope)
        XCTAssertEqual(fetchedSubmissions[0].id, "4")
        XCTAssertEqual(fetchedSubmissions[1].id, "2")
        XCTAssertEqual(fetchedSubmissions[2].id, "1")
        XCTAssertEqual(fetchedSubmissions[3].id, "3")
    }

    func testDeletesOldSubmissions() {
        Submission.save(.make(attempt: 0, workflow_state: .unsubmitted), in: databaseClient)
        XCTAssertEqual((databaseClient.fetch() as [Submission]).count, 1)

        let testee = GetSubmissions(context: .course("1"), assignmentID: "1", shuffled: false, filter: [.submitted])
        // Simulate Store executing these after API fetch completes
        testee.reset(context: databaseClient)
        testee.write(response: [.make(attempt: 1, workflow_state: .submitted)], urlResponse: nil, to: databaseClient)

        XCTAssertEqual((databaseClient.fetch() as [Submission]).count, 1)
    }

    func testSortMode() {
        // 1
        let useCase = GetSubmissions(context: .course("1"), assignmentID: "1", sortMode: .studentSortableName)

        XCTAssertEqual(useCase.scope.order, [
            NSSortDescriptor(key: #keyPath(Submission.user.sortableName), naturally: true),
            NSSortDescriptor(key: #keyPath(Submission.sortableName), naturally: true),
            NSSortDescriptor(key: #keyPath(Submission.userID), naturally: true)
        ])

        useCase.sortMode = .studentName
        XCTAssertEqual(useCase.scope.order, [
            NSSortDescriptor(key: #keyPath(Submission.user.name), naturally: true),
            NSSortDescriptor(key: #keyPath(Submission.userID), naturally: true)
        ])

        useCase.sortMode = .submissionDate
        XCTAssertEqual(useCase.scope.order, [
            NSSortDescriptor(key: #keyPath(Submission.submittedAt), ascending: true),
            NSSortDescriptor(key: #keyPath(Submission.userID), naturally: true)
        ])

        XCTAssertEqual(useCase.sortMode.query, URLQueryItem(name: "sort", value: "submissionDate"))

        useCase.sortMode = .submissionStatus
        XCTAssertEqual(useCase.scope.order, [
            NSSortDescriptor(key: #keyPath(Submission.workflowStateRaw), naturally: true),
            NSSortDescriptor(key: #keyPath(Submission.userID), naturally: true)
        ])

        XCTAssertEqual(useCase.sortMode.query, URLQueryItem(name: "sort", value: "submissionStatus"))
    }

    func testDifferentiationTagsFilterPredicate() throws {
        typealias Filter = GetSubmissions.Filter

        // Create users
        let user1 = User.save(.make(id: "1", name: "User 1"), in: databaseClient)
        let user2 = User.save(.make(id: "2", name: "User 2"), in: databaseClient)
        let user3 = User.save(.make(id: "3", name: "User 3"), in: databaseClient)

        // Create user group set
        let groupSet: CDUserGroupSet = databaseClient.insert()
        groupSet.id = "groupset1"
        groupSet.name = "Differentiation Tags"
        groupSet.courseId = "course1"

        // Create user groups (differentiation tags)
        let tag1: CDUserGroup = databaseClient.insert()
        tag1.id = "tag1"
        tag1.name = "Tag 1"
        tag1.isDifferentiationTag = true
        tag1.parentGroupSet = groupSet
        tag1.userIdsInGroup = Set(["1", "2"])

        let tag2: CDUserGroup = databaseClient.insert()
        tag2.id = "tag2"
        tag2.name = "Tag 2"
        tag2.isDifferentiationTag = true
        tag2.parentGroupSet = groupSet
        tag2.userIdsInGroup = Set(["2", "3"])

        // Connect users to their groups
        user1.userGroups = Set([tag1])
        user2.userGroups = Set([tag1, tag2])
        user3.userGroups = Set([tag2])

        // Create submissions
        let submission1 = Submission.save(.make(id: "1", user_id: "1"), in: databaseClient)
        let submission2 = Submission.save(.make(id: "2", user_id: "2"), in: databaseClient)
        let submission3 = Submission.save(.make(id: "3", user_id: "3"), in: databaseClient)

        submission1.user = user1
        submission2.user = user2
        submission3.user = user3

        try databaseClient.save()

        // Test filtering by tag1 - should return submissions for users 1 and 2
        let tag1Filter = [Filter.DifferentiationTag(tagID: "tag1")]
        let tag1Results: [Submission] = databaseClient.fetch(scope: .init(predicate: tag1Filter.predicate!, order: []))
        XCTAssertEqual(tag1Results.count, 2)
        XCTAssertTrue(tag1Results.contains { $0.userID == "1" })
        XCTAssertTrue(tag1Results.contains { $0.userID == "2" })

        // Test filtering by tag2 - should return submissions for users 2 and 3
        let tag2Filter = [Filter.DifferentiationTag(tagID: "tag2")]
        let tag2Results: [Submission] = databaseClient.fetch(scope: .init(predicate: tag2Filter.predicate!, order: []))
        XCTAssertEqual(tag2Results.count, 2)
        XCTAssertTrue(tag2Results.contains { $0.userID == "2" })
        XCTAssertTrue(tag2Results.contains { $0.userID == "3" })

        // Test filtering by both tags - should return all submissions (union)
        let bothTagsFilter = [Filter.DifferentiationTag(tagID: "tag1"), Filter.DifferentiationTag(tagID: "tag2")]
        let bothTagsResults: [Submission] = databaseClient.fetch(scope: .init(predicate: bothTagsFilter.predicate!, order: []))
        XCTAssertEqual(bothTagsResults.count, 3)

        // Test empty filter - should return nil predicate
        let emptyFilter: [Filter.DifferentiationTag] = []
        XCTAssertNil(emptyFilter.predicate)
    }
}
