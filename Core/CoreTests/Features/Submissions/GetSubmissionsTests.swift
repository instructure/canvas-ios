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

class GetRecentlyGradedSubmissionsTests: CoreTestCase {
    func testRequestUsesUserID() {
        let useCase = GetRecentlyGradedSubmissions(userID: "1")
        XCTAssertEqual(useCase.request.userID, "1")
    }

    func testItCreatesSubmissionsWithAssignments() {
        let apiSubmission = APISubmission.make(
            assignment: APIAssignment.make(id: "2", submission: nil),
            assignment_id: "2",
            id: "1"
        )

        let useCase = GetRecentlyGradedSubmissions(userID: "1")
        useCase.write(response: [apiSubmission], urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)
        XCTAssertEqual(submissions[0].id, "1")
        XCTAssertEqual(submissions[0].assignmentID, "2")

        let assignments: [Assignment] = databaseClient.fetch()
        XCTAssertEqual(assignments.count, 1)
        XCTAssertEqual(assignments[0].id, "2")
        XCTAssertEqual(assignments[0].submission, submissions[0])
    }

    func testCache() {
        let useCase = GetRecentlyGradedSubmissions(userID: "self")
        XCTAssertEqual(useCase.cacheKey, "recently-graded-submissions")
    }
}

class CreateSubmissionTests: CoreTestCase {
    func testItCreatesAssignmentSubmission() {
        //  given
        let submissionType = SubmissionType.online_url
        let context = Context(.course, id: "1")
        let url = URL(string: "http://www.instructure.com")!
        let template: APISubmission = APISubmission.make(
            assignment_id: "1",
            excused: true,
            grade: "A-",
            late: true,
            late_policy_status: .late,
            missing: true,
            points_deducted: 10,
            score: 97,
            workflow_state: .submitted
        )

        //  when
        let createSubmission = CreateSubmission(context: context, assignmentID: "1", userID: "1", submissionType: submissionType, url: url)
        createSubmission.write(response: template, urlResponse: nil, to: databaseClient)

        //  then
        let subs: [Submission] = databaseClient.fetch(scope: createSubmission.scope)
        let submission = subs.first
        XCTAssertNotNil(submission)
        XCTAssertEqual(submission?.grade, "A-")
        XCTAssertEqual(submission?.late, true)
        XCTAssertEqual(submission?.excused, true)
        XCTAssertEqual(submission?.missing, true)
        XCTAssertEqual(submission?.workflowState, .submitted)
        XCTAssertEqual(submission?.latePolicyStatus, .late)
        XCTAssertEqual(submission?.pointsDeducted, 10)
    }

    func testItPostsModuleCompletedRequirement() {
        let context = Context(.course, id: "1")
        let request = CreateSubmissionRequest(context: context, assignmentID: "2", body: .init(submission: .init(group_comment: nil, submission_type: .online_text_entry)))
        api.mock(request, value: nil)
        let expectation = XCTestExpectation(description: "notification")
        let token = NotificationCenter.default.addObserver(forName: .CompletedModuleItemRequirement, object: nil, queue: nil) { notification in
            XCTAssertEqual(notification.userInfo?["requirement"] as? ModuleItemCompletionRequirement, .submit)
            XCTAssertEqual(notification.userInfo?["moduleItem"] as? ModuleItemType, .assignment("2"))
            XCTAssertEqual(notification.userInfo?["courseID"] as? String, "1")
            expectation.fulfill()
        }
        let useCase = CreateSubmission(context: context, assignmentID: "2", userID: "3", submissionType: .online_text_entry)
        useCase.makeRequest(environment: environment) { _, _, _ in }
        wait(for: [expectation], timeout: 0.5)
        NotificationCenter.default.removeObserver(token)
    }

    func testItDoesNotPostModuleCompletedRequirementIfError() {
        let context = Context(.course, id: "1")
        let request = CreateSubmissionRequest(context: context, assignmentID: "2", body: .init(submission: .init(group_comment: nil, submission_type: .online_text_entry)))
        api.mock(request, error: NSError.instructureError("oops"))
        let expectation = XCTestExpectation(description: "notification")
        expectation.isInverted = true
        let token = NotificationCenter.default.addObserver(forName: .CompletedModuleItemRequirement, object: nil, queue: nil) { _ in
            expectation.fulfill()
        }
        let useCase = CreateSubmission(context: context, assignmentID: "2", userID: "3", submissionType: .online_text_entry)
        useCase.makeRequest(environment: environment) { _, _, _ in }
        wait(for: [expectation], timeout: 0.2)
        NotificationCenter.default.removeObserver(token)
    }
}

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
            NSSortDescriptor(key: #keyPath(Submission.sortableName), naturally: true),
            NSSortDescriptor(key: #keyPath(Submission.user.sortableName), naturally: true),
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

        XCTAssertEqual(useCase.scopeKeepingIDs(["3"]).predicate, NSCompoundPredicate(andPredicateWithSubpredicates: [
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
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSCompoundPredicate(andPredicateWithSubpredicates: []),
                NSPredicate(format: "%K IN %@", #keyPath(Submission.userID), ["3"])
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
        typealias Filter = GetSubmissions.Filter
        XCTAssertEqual(Filter(rawValue: nil), nil)
        XCTAssertEqual(Filter(rawValue: "bogus" as String?), nil)
        XCTAssertEqual(Filter(rawValue: "late"), .late)
        XCTAssertEqual(Filter.late.rawValue, "late")
        XCTAssertEqual(Filter(rawValue: "not_submitted"), .notSubmitted)
        XCTAssertEqual(Filter.notSubmitted.rawValue, "not_submitted")
        XCTAssertEqual(Filter(rawValue: "needs_grading"), .needsGrading)
        XCTAssertEqual(Filter.needsGrading.rawValue, "needs_grading")
        XCTAssertEqual(Filter(rawValue: "graded"), .graded)
        XCTAssertEqual(Filter.graded.rawValue, "graded")
        XCTAssertEqual(Filter(rawValue: "score_above_10"), .scoreAbove(10))
        XCTAssertEqual(Filter.scoreAbove(1.5).rawValue, "score_above_1.5")
        XCTAssertEqual(Filter(rawValue: "score_below_0.7"), .scoreBelow(0.7))
        XCTAssertEqual(Filter.scoreBelow(-2).rawValue, "score_below_-2.0")
        XCTAssertEqual(Filter(rawValue: "user_7"), .user("7"))
        XCTAssertEqual(Filter.user("a").rawValue, "user_a")
        XCTAssertEqual(Filter(rawValue: "section_a_2"), .section([ "a", "2" ]))
        XCTAssertEqual(Filter.section([ "c", "1" ]).rawValue, "section_1_c")
    }

    func testGetSubmissionsFilterPredicate() {
        typealias Filter = GetSubmissions.Filter
        XCTAssertEqual(Filter.late.predicate, NSPredicate(key: #keyPath(Submission.late), equals: true))
        XCTAssertEqual(
            Filter.notSubmitted.predicate,
            NSCompoundPredicate(type: .and, subpredicates: [
                NSPredicate(key: #keyPath(Submission.submittedAt), equals: nil),
                NSPredicate(key: #keyPath(Submission.workflowStateRaw), equals: SubmissionWorkflowState.unsubmitted.rawValue)
            ])
        )
        XCTAssertEqual(Filter.graded.predicate, NSPredicate(format: "%K == true OR (%K != nil AND %K == 'graded')",
            #keyPath(Submission.excusedRaw),
            #keyPath(Submission.scoreRaw),
            #keyPath(Submission.workflowStateRaw)
        ))
        XCTAssertEqual(Filter.scoreAbove(100).predicate, NSPredicate(format: "%K > %@", #keyPath(Submission.scoreRaw), NSNumber(value: 100.0)))
        XCTAssertEqual(Filter.scoreBelow(0).predicate, NSPredicate(format: "%K < %@", #keyPath(Submission.scoreRaw), NSNumber(value: 0.0)))
        XCTAssertEqual(Filter.user("1").predicate, NSPredicate(key: #keyPath(Submission.userID), equals: "1"))
        XCTAssertEqual(Filter.section([ "c", "1" ]).predicate, NSPredicate(format: "ANY %K IN %@", #keyPath(Submission.enrollments.courseSectionID), Set([ "c", "1" ])))
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
        XCTAssertEqual(Filter.late.name, "Late")
        XCTAssertEqual(Filter.notSubmitted.name, "Not Submitted")
        XCTAssertEqual(Filter.needsGrading.name, "Needs Grading")
        XCTAssertEqual(Filter.graded.name, "Graded")
        XCTAssertEqual(Filter.scoreAbove(100).name, "Scored above 100")
        XCTAssertEqual(Filter.scoreBelow(0).name, "Scored below 0")
        XCTAssertEqual(Filter.user("1").name, "Me")
        XCTAssertEqual(Filter.section([ "2", "1" ]).name, "One and Two")
    }

    func testGroupSubmissionWithIndividualGradesOrder() {
        let date = Date()
        let group = APISubmissionGroup(id: nil, name: "Group 1")
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

        let testee = GetSubmissions(context: .course("1"), assignmentID: "1", filter: [.needsGrading], shuffled: false)
        // Simulate Store executing these after API fetch completes
        testee.reset(context: databaseClient)
        testee.write(response: [.make(attempt: 1, workflow_state: .submitted)], urlResponse: nil, to: databaseClient)

        XCTAssertEqual((databaseClient.fetch() as [Submission]).count, 1)
    }
}
