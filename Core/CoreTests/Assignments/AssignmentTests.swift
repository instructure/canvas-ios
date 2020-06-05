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

import Foundation
import XCTest
@testable import Core
import MobileCoreServices

class AssignmentTests: CoreTestCase {

    override func setUp() {
        super.setUp()
        Clock.reset()
    }

    func testUpdateFromAPIItemWithAPISubmission() {
        let client = databaseClient
        let a = Assignment.make(from: .make(name: "a", submission: nil))
        let api = APIAssignment.make(name: "api_a", submission: .make())

        XCTAssertNil(a.submission)

        a.update(fromApiModel: api, in: client, updateSubmission: true)

        XCTAssertEqual(a.id, api.id.value)
        XCTAssertEqual(a.name, api.name)
        XCTAssertEqual(a.courseID, api.course_id.value)
        XCTAssertEqual(a.details, api.description)
        XCTAssertEqual(a.pointsPossible, api.points_possible)
        XCTAssertEqual(a.dueAt, api.due_at)
        XCTAssertEqual(a.htmlURL, api.html_url)
        XCTAssertEqual(a.gradingType, api.grading_type)
        XCTAssertEqual(a.submissionTypes, api.submission_types)
        XCTAssertEqual(a.position, api.position)
        XCTAssertFalse(a.useRubricForGrading)
        XCTAssertFalse(a.hideRubricPoints)
        XCTAssertFalse(a.freeFormCriterionCommentsOnRubric)

        XCTAssertNotNil(a.submission)
    }

    func testUpdateFromAPIItemWithAPISubmissionButDoNotMutateSubmission() {
        let client = databaseClient
        let a = Assignment.make(from: .make(name: "a", submission: nil))
        let api = APIAssignment.make(name: "api_a", submission: .make())

        XCTAssertNil(a.submission)

        a.update(fromApiModel: api, in: client, updateSubmission: false)

        XCTAssertNil(a.submission)
    }

    func testUpdateFromAPIItemWithExistingSubmission() {
        let client = databaseClient
        let a = Assignment.make(from: .make(name: "a", submission: .make(grade: "A")))
        let api = APIAssignment.make(name: "api_a", submission: nil)
        XCTAssertNil(api.submission)

        a.update(fromApiModel: api, in: client, updateSubmission: true)
        XCTAssertNil(a.submission)

        let list: [Assignment] = client.fetch(NSPredicate(format: "%K == %@", #keyPath(Assignment.id), a.id))
        let result = list.first
        XCTAssertNotNil(result)
        XCTAssertNil(result?.submission)
    }

    func testCanMakeSubmissions() {
        XCTAssertTrue(Assignment.make(from: .make(submission_types: [.online_upload])).canMakeSubmissions)
        XCTAssertFalse(Assignment.make(from: .make(submission_types: [.none])).canMakeSubmissions)
        XCTAssertFalse(Assignment.make(from: .make(submission_types: [.on_paper])).canMakeSubmissions)
        XCTAssertFalse(Assignment.make(from: .make(submission_types: [])).canMakeSubmissions)
        XCTAssertFalse(Assignment.make(from: .make(submission_types: [.wiki_page])).canMakeSubmissions)
    }

    func testIsLTIAssignment() {
        let a = Assignment.make()
        a.submissionTypes = [.external_tool]
        XCTAssertTrue(a.isLTIAssignment)
    }

    func testIsDiscussion() {
        let a = Assignment.make(from: .make(submission_types: [ .discussion_topic ] ))
        XCTAssertTrue(a.isDiscussion)
        a.submissionTypes.append(.basic_lti_launch)
        XCTAssertFalse(a.isDiscussion)
    }

    func testViewableScore() {
        let a = Assignment.make()
        XCTAssertNil(a.viewableScore)
        a.submission = Submission.make(from: .make(score: 10))
        XCTAssertEqual(a.viewableScore, 10)
    }

    func testViewableGrade() {
        let a = Assignment.make()
        XCTAssertNil(a.viewableGrade)
        a.submission = Submission.make(from: .make(grade: "C"))
        XCTAssertEqual(a.viewableGrade, "C")
    }

    func testDescriptionHTML() {
        let a = Assignment.make(from: .make(description: nil))
        XCTAssertEqual(a.descriptionHTML, "<i>No Content</i>")
        a.details = "details"
        XCTAssertEqual(a.descriptionHTML, "details")
        a.submissionTypes = [.discussion_topic]
        XCTAssertEqual(a.descriptionHTML, "<i>No Content</i>")
        a.discussionTopic = DiscussionTopic.make()
        XCTAssertEqual(a.descriptionHTML, DiscussionHTML.string(for: a.discussionTopic!))
    }

    func testUseRubricForGrading() {
        let apiAssignment = APIAssignment.make(use_rubric_for_grading: true)
        let assignment = Assignment.make()

        assignment.update(fromApiModel: apiAssignment, in: databaseClient, updateSubmission: true)

        XCTAssertTrue(assignment.useRubricForGrading)
    }

    func testLockStatusUnlocked() {
        let assignment = Assignment.make()
        XCTAssertEqual(assignment.lockStatus, .unlocked)
    }

    func testLockStatusBefore() {
        let assignment = Assignment.make(from: .make(unlock_at: Date().addYears(1), locked_for_user: true))
        XCTAssertEqual(assignment.lockStatus, .before)
    }

    func testLockStatusAfter() {
        let assignment = Assignment.make(from: .make(lock_at: Date().addYears(-1), locked_for_user: true))
        XCTAssertEqual(assignment.lockStatus, .after)
    }

    func testIconForDiscussion() {
        let a = Assignment.make(from: .make(id: "1", submission_types: [ .discussion_topic ]))
        let icon = a.icon
        let expected = UIImage.icon(.discussion, .line)
        XCTAssertEqual(icon, expected)
    }

    func testIconForAssignment() {
        let a = Assignment.make(from: .make(id: "1"))
        let icon = a.icon
        let expected = UIImage.icon(.assignment, .line)
        XCTAssertEqual(icon, expected)
    }

    func testIconForQuiz() {
        let a = Assignment.make(from: .make(id: "1", quiz_id: "1"))
        let icon = a.icon
        let expected = UIImage.icon(.quiz, .line)
        XCTAssertEqual(icon, expected)
    }

    func testIconForExternalTool() {
        let a = Assignment.make(from: .make(id: "1", submission_types: [ .external_tool ]))
        let icon = a.icon
        let expected = UIImage.icon(.lti, .line)
        XCTAssertEqual(icon, expected)
    }

    func testIconForLocked() {
        let a = Assignment.make(from: .make(id: "1", submission_types: [ .external_tool ], locked_for_user: true))
        let icon = a.icon
        let expected = UIImage.icon(.lock, .line)
        XCTAssertEqual(icon, expected)
    }

    func testMutlipleSubmissions() {
        let a = APISubmission.make(id: "1", assignment_id: "1", user_id: "1")
        let b = APISubmission.make(id: "2", assignment_id: "1", user_id: "2")
        let assignment = Assignment.make(from: APIAssignment.make(submissions: [a, b]), in: databaseClient)

        XCTAssertEqual(assignment.submissions?.count, 2)
        let submissions = assignment.submissions?.sorted(by: { (s1, s2) -> Bool in
            return s1.id < s2.id
        })
        XCTAssertEqual(submissions?.first?.id, "1")
        XCTAssertEqual(submissions?.last?.id, "2")
    }

    func testRequiresLTILaunchToViewSubmission() {
        let onPaper = Assignment.make(from: .make(id: "1", submission_types: [.on_paper]))
        let externalTool = Assignment.make(from: .make(id: "2", submission_types: [.external_tool]))
        let onlineUploadWithAttachment = Submission.make(from: .make(submission_type: .online_upload, attempt: 1, attachments: [.make(id: "1")]))
        let onlineUploadWithoutAttachment = Submission.make(from: .make(submission_type: .online_upload, attempt: 2, attachments: []))
        let onlineQuizWithAttachment = Submission.make(from: .make(submission_type: .online_quiz, attempt: 3, attachments: [.make(id: "2")]))
        XCTAssertFalse(onPaper.requiresLTILaunch(toViewSubmission: onlineUploadWithAttachment))
        XCTAssertFalse(externalTool.requiresLTILaunch(toViewSubmission: onlineUploadWithAttachment))
        XCTAssertTrue(externalTool.requiresLTILaunch(toViewSubmission: onlineUploadWithoutAttachment))
        XCTAssertTrue(externalTool.requiresLTILaunch(toViewSubmission: onlineQuizWithAttachment))
    }

    func testIsOpenForSubmissions() {
        let df = ISO8601DateFormatter()
        let a = Assignment.make(from: .make(unlock_at: nil, lock_at: nil))
        let now = df.date(from: "2018-10-01T06:00:00Z")!
        Clock.mockNow(now)

        a.lockAt = df.date(from: "2018-10-01T06:00:00Z")
        XCTAssertFalse(a.isOpenForSubmissions())
        a.lockAt = df.date(from: "2018-10-01T05:59:59Z")
        XCTAssertFalse(a.isOpenForSubmissions())

        a.lockAt = nil
        a.unlockAt = df.date(from: "2018-10-01T06:00:00Z")
        XCTAssertTrue(a.isOpenForSubmissions())
        a.unlockAt = df.date(from: "2018-10-01T06:00:01Z")
        XCTAssertFalse(a.isOpenForSubmissions())

        a.unlockAt = df.date(from: "2018-10-01T05:00:00Z")
        a.lockAt   = df.date(from: "2018-10-01T06:01:00Z")
        XCTAssertTrue(a.isOpenForSubmissions())

        Clock.mockNow(df.date(from: "2018-10-01T06:02:00Z")!)
        XCTAssertFalse(a.isOpenForSubmissions())

        Clock.mockNow(now)
        a.lockedForUser = true
        a.unlockAt = df.date(from: "2018-10-01T05:00:00Z")
        a.lockAt   = df.date(from: "2018-10-01T06:01:00Z")
        XCTAssertFalse(a.isOpenForSubmissions())

        a.lockedForUser = false
        a.unlockAt = df.date(from: "2018-10-01T05:00:00Z")
        a.lockAt   = df.date(from: "2018-10-01T06:01:00Z")
        XCTAssertTrue(a.isOpenForSubmissions())
    }

    func testAllDates() {
        let a = Assignment.make(from: .make(all_dates: [
            .make(
                due_at: DateComponents(calendar: .current, year: 2020, month: 6, day: 1).date
            ),
        ]))
        XCTAssertEqual(a.allDates.count, 1)
    }
}
