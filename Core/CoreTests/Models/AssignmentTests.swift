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

class AssignmentTests: CoreTestCase {

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
        //  given
        let a = Assignment.make()
        a.submissionTypes = [.online_upload]

        //  when
        let result = a.canMakeSubmissions

        //  then
        XCTAssertTrue(result)
    }

    func testCannotMakeSubmissions() {
        //  given
        let a = Assignment.make()
        a.submissionTypes = [.none]

        //  when
        let result = a.canMakeSubmissions

        //  then
        XCTAssertFalse(result)
    }

    func testCannotMakeSubmissionsOnPaper() {
        //  given
        let a = Assignment.make()
        a.submissionTypes = [.on_paper]

        //  when
        let result = a.canMakeSubmissions

        //  then
        XCTAssertFalse(result)
    }

    func testCannotMakeSubmissionsWithNoSubmissionTypes() {
        //  given
        let a = Assignment.make()
        a.submissionTypes = []

        //  when
        let result = a.canMakeSubmissions

        //  then
        XCTAssertFalse(result)
    }

    func testAllowedUTIsNoneIsEmpty() {
        let a = Assignment.make()
        a.submissionTypes = [.none]
        a.allowedExtensions = ["png"]
        XCTAssertTrue(a.allowedUTIs.isEmpty)
    }

    func testAllowedUTIsAny() {
        let a = Assignment.make()
        a.submissionTypes = [.online_upload]
        a.allowedExtensions = []
        XCTAssertEqual(a.allowedUTIs, [.any])
    }

    func testAllowedUTIsAllowedExtensions() {
        let a = Assignment.make()
        a.submissionTypes = [.online_upload]
        a.allowedExtensions = ["png", "mov", "mp3"]
        let result = a.allowedUTIs
        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result[0].isImage)
        XCTAssertTrue(result[1].isVideo)
        XCTAssertTrue(result[2].isAudio)
    }

    func testAllowedUTIsAllowedExtensionsVideo() {
        let a = Assignment.make()
        a.submissionTypes = [.online_upload]
        a.allowedExtensions = ["mov", "mp4"]
        let result = a.allowedUTIs
        XCTAssertTrue(result[0].isVideo)
        XCTAssertTrue(result[1].isVideo)
    }

    func testAllowedUTIsMediaRecording() {
        let a = Assignment.make()
        a.submissionTypes = [.media_recording]
        XCTAssertEqual(a.allowedUTIs, [.video, .audio])
    }

    func testAllowedUTIsText() {
        let a = Assignment.make()
        a.submissionTypes = [.online_text_entry]
        XCTAssertEqual(a.allowedUTIs, [.text])
    }

    func testAllowedUTIsURL() {
        let a = Assignment.make()
        a.submissionTypes = [.online_url]
        XCTAssertEqual(a.allowedUTIs, [.url])
    }

    func testAllowedUTIsMultipleSubmissionTypes() {
        let a = Assignment.make()
        a.submissionTypes = [
            .online_upload,
            .online_text_entry,
        ]
        a.allowedExtensions = ["jpeg"]
        let result = a.allowedUTIs
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result[0].isImage)
        XCTAssertEqual(result[1], .text)
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
        XCTAssertEqual(a.descriptionHTML, a.discussionTopic?.html)
    }

    func testGradeTextReturnsNil() {
        let a = Assignment.make()
        XCTAssertNil(a.gradeText)
    }

    func testGradeTextReturnsGPA() {
        let a = Assignment.make()
        a.gradingType = .gpa_scale
        let s = Submission.make()
        s.grade = "3.0"
        a.submission = s
        XCTAssertEqual(a.gradeText, "3.0 GPA")
    }

    func testGradeTextReturnsPassFail() {
        let a = Assignment.make()
        a.gradingType = .pass_fail
        let s = Submission.make()
        s.grade = "incomplete"
        a.submission = s
        XCTAssertEqual(a.gradeText, "Incomplete")
        s.grade = "complete"
        XCTAssertEqual(a.gradeText, "Complete")
    }

    func testGradeTextReturnsPoints() {
        let a = Assignment.make()
        a.gradingType = .points
        a.pointsPossible = 100
        let s = Submission.make()
        s.score = 50
        a.submission = s
        XCTAssertEqual(a.gradeText, "50")
    }

    func testGradeTextReturnsOthers() {
        let a = Assignment.make()
        a.gradingType = .percent
        let s = Submission.make()
        s.grade = "80%"
        a.submission = s
        XCTAssertEqual(a.gradeText, "80%")

        a.gradingType = .letter_grade
        s.grade = "A+"
        XCTAssertEqual(a.gradeText, "A+")

        a.gradingType = .not_graded
        s.grade = ""
        XCTAssertEqual(a.gradeText, "")
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

    func testSubmissionStatusTextSubmissionMissingPastDue() {
        let a = Assignment.make(from: .make(id: "2", due_at: Date().addDays(-2), submission: nil))
        let result = a.submissionStatusText
        let expected = "missing"
        XCTAssertEqual(result, expected)
    }

    func testSubmissionStatusTextUnsubmitted() {
        let s = APISubmission.make(workflow_state: .unsubmitted)
        let a = Assignment.make(from: .make(id: "3", due_at: Date().addDays(-3), submission: s))
        let result = a.submissionStatusText
        let expected = "missing"
        XCTAssertEqual(result, expected)
    }

    func testSubmissionStatusTextSubmissionMissing() {
        let s = APISubmission.make(missing: true)
        let a = Assignment.make(from: .make(id: "4", due_at: Date().addDays(-4), submission: s))
        let result = a.submissionStatusText
        let expected = "missing"
        XCTAssertEqual(result, expected)
    }

    func testSubmissionStatusTextSubmissionLate() {
        let s = APISubmission.make(late: true)
        let a = Assignment.make(from: .make(id: "5", submission: s))
        let result = a.submissionStatusText
        let expected = "late"
        XCTAssertEqual(result, expected)
    }

    func testSubmissionStatusTextSubmitted() {
        let s = APISubmission.make(submission_type: .online_text_entry)
        let a = Assignment.make(from: .make(id: "6", submission: s))
        let result = a.submissionStatusText
        let expected = "submitted"
        XCTAssertEqual(result, expected)
    }

    func testNewVarsAddedByGrades() {
        XCTFail("implement me")
    }
}
