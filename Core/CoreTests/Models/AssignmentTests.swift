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

    func testAllowedMediaTypesForMediaRecordings() {
        let a = Assignment.make()
        a.submissionTypes = [.media_recording]
        XCTAssertEqual(a.allowedMediaTypes, [kUTTypeMovie as String, kUTTypeAudio as String])

        let b = Assignment.make()
        b.submissionTypes = [.media_recording, .online_upload]
        XCTAssertEqual(b.allowedMediaTypes, [kUTTypeMovie as String, kUTTypeImage as String])
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

    func testGradesListGradeTextWithNoSubmission() {
        let a = Assignment.make(from: .make(id: "6", submission: nil))
        let result = a.multiUserSubmissionGradeText(studentID: "1")
        XCTAssertNil(result)
    }

    func testGradesListGradeTextWithExcusedSubmission() {
        let s = APISubmission.make(excused: true)
        let a = Assignment.make(from: .make(id: "6", submission: s))
        let result = a.multiUserSubmissionGradeText(studentID: "1")
        let expected = "Excused"
        XCTAssertEqual(result, expected)
    }

    func testGradesListGradeTextWithNilSubmissionScore() {
        let s = APISubmission.make(score: nil)
        let a = Assignment.make(from: .make(id: "6", submission: s))
        let result = a.multiUserSubmissionGradeText(studentID: "1")
        XCTAssertNil(result)
    }

    func testGradesListGradeTextWithPassFailGradeTypeIncomplete() {
        let s = APISubmission.make(grade: "incomplete", score: 6)
        let a = Assignment.make(from: .make(id: "6", submission: s, grading_type: .pass_fail))
        let result = a.multiUserSubmissionGradeText(studentID: "1")
        let expected = "Incomplete"
        XCTAssertEqual(result, expected)
    }

    func testGradesListGradeTextWithPassFailGradeTypeComplete() {
        let s1 = APISubmission.make(id: "1", user_id: "1", grade: "complete", score: 6)
        let s2 = APISubmission.make(id: "2", user_id: "2", grade: "complete", score: 6)
        let s3 = APISubmission.make(id: "3", user_id: "3", grade: "complete", score: 6)
        let s4 = APISubmission.make(id: "4", user_id: "4", grade: "complete", score: 6)
        let a = Assignment.make(from: .make(id: "6", submissions: [s1, s2, s3, s4], grading_type: .pass_fail))
        let result = a.multiUserSubmissionGradeText(studentID: "1")
        let expected = "Complete"
        XCTAssertEqual(result, expected)
    }

    func testGradesListGradeTextWithNoStudentIDSubmissions() {
        let s1 = APISubmission.make(id: "1", user_id: "1", grade: "complete", score: 6)
        let s2 = APISubmission.make(id: "2", user_id: "2", grade: "complete", score: 6)
        let s3 = APISubmission.make(id: "3", user_id: "3", grade: "complete", score: 6)
        let s4 = APISubmission.make(id: "4", user_id: "4", grade: "complete", score: 6)
        let a = Assignment.make(from: .make(id: "6", submissions: [s1, s2, s3, s4], grading_type: .pass_fail))
        let result = a.multiUserSubmissionGradeText(studentID: "5")
        XCTAssertNil(result)
    }

    func testGradesListGradeTextWithPoints() {
        let s = APISubmission.make(score: 5)
        let a = Assignment.make(from: .make(id: "6", submission: s, grading_type: .points))
        let result = a.multiUserSubmissionGradeText(studentID: "1")
        let expected = "5 out of 10"
        XCTAssertEqual(result, expected)
    }

    func testGradesListGradeTextWithPointsFixME() {
        let s = APISubmission.make(grade: "75%", score: 76.0)
        let a = Assignment.make(from: .make(id: "6", points_possible: 111.8, submission: s, grading_type: .percent))
        let result = a.multiUserSubmissionGradeText(studentID: "1")
        let expected = "76 out of 111.8 (75%)"
        XCTAssertEqual(result, expected)
    }

    func testGradesListGradeTextWithLetterGrade() {
        let s = APISubmission.make(grade: "A", score: 5)
        let a = Assignment.make(from: .make(id: "6", submission: s, grading_type: .letter_grade))
        let result = a.multiUserSubmissionGradeText(studentID: "1")
        let expected = "5 out of 10 (A)"
        XCTAssertEqual(result, expected)
    }

    func testGradesListGradeTexNotGraded() {
        let s = APISubmission.make(grade: "A", score: 5)
        let a = Assignment.make(from: .make(id: "6", submission: s, grading_type: .not_graded))
        let result = a.multiUserSubmissionGradeText(studentID: "1")
        XCTAssertNil(result)
    }

    func testSubmissionStatusLabelNoSubmission() {
        let a = Assignment.make(from: .make(id: "6", submission: nil))
        let result = a.submissionStatus
        let expected = "Not Submitted"
        XCTAssertEqual(result, expected)
    }

    func testSubmissionStatusLabelExcused() {
        let s = APISubmission.make(excused: true)
        let a = Assignment.make(from: .make(id: "6", submission: s))
        let result = a.submissionStatus
        let expected = ""
        XCTAssertEqual(result, expected)
    }

    func testSubmissionStatusLabelLate() {
        let s = APISubmission.make(late: true)
        let a = Assignment.make(from: .make(id: "6", submission: s))
        let result = a.submissionStatus
        let expected = "Late"
        XCTAssertEqual(result, expected)
    }

    func testSubmissionStatusLabelMissing() {
        let s = APISubmission.make(missing: true)
        let a = Assignment.make(from: .make(id: "6", submission: s))
        let result = a.submissionStatus
        let expected = "Missing"
        XCTAssertEqual(result, expected)
    }

    func testSubmissionStatusLabelSubmitted() {
        let s = APISubmission.make(submitted_at: Date().addYears(-1))
        let a = Assignment.make(from: .make(id: "6", submission: s))
        let result = a.submissionStatus
        let expected = "Submitted"
        XCTAssertEqual(result, expected)
    }

    func testSubmissionStatusLabelOfflineSubmssionTypeOffline() {
        var s = APISubmission.make(submitted_at: Date().addYears(-1))
        var a = Assignment.make(from: .make(id: "1", submission: s, submission_types: [.none]))
        var result = a.submissionStatus
        let expected = ""
        XCTAssertEqual(result, expected)

        s = APISubmission.make(submitted_at: Date().addYears(-1))
        a = Assignment.make(from: .make(id: "2", submission: s, submission_types: [.not_graded]))
        result = a.submissionStatus
        XCTAssertEqual(result, expected)

        s = APISubmission.make(submitted_at: Date().addYears(-1))
        a = Assignment.make(from: .make(id: "3", submission: s, submission_types: [.on_paper]))
        result = a.submissionStatus
        XCTAssertEqual(result, expected)
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
}
