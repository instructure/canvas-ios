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

class SubmissionTests: CoreTestCase {
    func testProperties() {
        let submission = Submission.make()

        submission.latePolicyStatus = nil
        XCTAssertNil(submission.latePolicyStatus)
        submission.latePolicyStatus = .late
        XCTAssertEqual(submission.latePolicyStatus, .late)

        submission.pointsDeducted = nil
        XCTAssertNil(submission.pointsDeducted)
        submission.pointsDeducted = 5
        XCTAssertEqual(submission.pointsDeducted, 5)

        submission.score = nil
        XCTAssertNil(submission.score)
        submission.score = 10
        XCTAssertEqual(submission.score, 10)

        submission.type = nil
        XCTAssertNil(submission.type)
        submission.type = .online_upload
        XCTAssertEqual(submission.type, .online_upload)

        submission.workflowState = .submitted
        XCTAssertEqual(submission.workflowState, .submitted)
        submission.workflowStateRaw = "bogus"
        XCTAssertEqual(submission.workflowState, .unsubmitted)

        submission.discussionEntries = [
            DiscussionEntry.make(from: .make(id: "2")),
            DiscussionEntry.make(from: .make(id: "1"))
        ]
        XCTAssertEqual(submission.discussionEntriesOrdered.first?.id, "1")

        let date = Date(timeIntervalSinceNow: 0)
        submission.gradedAt = nil
        XCTAssertNil(submission.gradedAt)
        submission.gradedAt = date
        XCTAssertEqual(submission.gradedAt, date)

        XCTAssertEqual(submission.shuffleOrder, "c4ca4238a0b923820dcc509a6f75849b")
    }

    func testMediaSubmission() {
        let submission = Submission.make(from: .make(media_comment: .make()))
        XCTAssertNotNil(submission.mediaComment)
    }

    func testAttemptIcon() {
        let submission = Submission.make()
        let map: [SubmissionType: UIImage] = [
            .basic_lti_launch: .ltiLine,
            .external_tool: .ltiLine,
            .discussion_topic: .discussionLine,
            .online_quiz: .quizLine,
            .online_text_entry: .textLine,
            .online_url: .linkLine,
            .student_annotation: .annotateLine
        ]
        for (type, icon) in map {
            submission.type = type
            XCTAssertEqual(submission.attemptIcon, icon)
        }
        submission.type = .media_recording
        submission.mediaComment = MediaComment.make(from: .make(media_type: .audio))
        XCTAssertEqual(submission.attemptIcon, UIImage.audioLine)
        submission.mediaComment?.mediaType = .video
        XCTAssertEqual(submission.attemptIcon, UIImage.videoLine)

        submission.type = .online_upload
        submission.attachments = Set([ File.make(from: .make(contentType: "application/pdf", mime_class: "pdf")) ])
        XCTAssertEqual(submission.attemptIcon, UIImage.pdfLine)

        submission.type = .on_paper
        XCTAssertNil(submission.attemptIcon)

        submission.type = nil
        XCTAssertNil(submission.attemptIcon)
    }

    func testAttemptTitle() {
        let submission = Submission.make()
        submission.type = .discussion_topic

        XCTAssertEqual(submission.attemptTitle, "Discussion Comment")
    }

    func testAttemptSubtitle() {
        let submission = Submission.make(from: .make(
            attachments: [ .make(size: 1234) ],
            attempt: 1,
            body: "<a style=\"stuff\">Some text</z><br>New line<div>And another</div>",
            discussion_entries: [ .make(message: "<p>reply<p><br>New line<div>And another</div>") ],
            url: URL(string: "https://instructure.com")
        ))
        let map: [SubmissionType: String?] = [
            .discussion_topic: "reply New line And another",
            .external_tool: "Attempt 1",
            // .media_recording: nil, // testing variants below
            .none: nil,
            .not_graded: nil,
            .online_quiz: "Attempt 1",
            .online_text_entry: "Some text New line And another",
            .online_upload: "1 KB",
            .online_url: "https://instructure.com",
            .on_paper: nil,
            .basic_lti_launch: "Attempt 1",
            .wiki_page: nil,
            .student_annotation: nil
        ]
        for (type, subtitle) in map {
            submission.type = type
            XCTAssertEqual(submission.attemptSubtitle, subtitle)
        }

        submission.type = .media_recording
        submission.mediaComment = MediaComment.make(from: .make(media_type: .audio))
        XCTAssertEqual(submission.attemptSubtitle, "Audio")
        submission.mediaComment?.mediaType = .video
        XCTAssertEqual(submission.attemptSubtitle, "Video")
    }

    func testAttemptAccessibilityDescription() {
        let submission = Submission.make(from: .make(
            attachments: [ .make(size: 1234) ],
            attempt: 1,
            body: "<a style=\"stuff\">Some text</z><br>New line<div>And another</div>",
            discussion_entries: [ .make(message: "<p>reply<p><br>New line<div>And another</div>") ],
            url: URL(string: "https://instructure.com")
        ))
        let map: [SubmissionType: String?] = [
            .discussion_topic: "Discussion Comment, reply",
            .external_tool: "External Tool",
            // .media_recording: nil, // testing variants below
            .none: "No Submission",
            .not_graded: "Not Graded",
            .online_quiz: "Quiz",
            .online_text_entry: "Text Entry, Some text",
            .online_upload: "File Upload",
            .online_url: "Website URL, https://instructure.com",
            .on_paper: "On Paper",
            .basic_lti_launch: "External Tool",
            .wiki_page: "Page",
            .student_annotation: "Student Annotation"
        ]
        for (type, subtitle) in map {
            submission.type = type
            XCTAssertEqual(submission.attemptAccessibilityDescription, subtitle)
        }

        submission.type = .media_recording
        submission.mediaComment = MediaComment.make(from: .make(media_type: .audio))
        XCTAssertEqual(submission.attemptAccessibilityDescription, "Media Recording, Audio")
        submission.mediaComment?.mediaType = .video
        XCTAssertEqual(submission.attemptAccessibilityDescription, "Media Recording, Video")
    }

    func testAttemptPropertiesWhenQuizLTI() {
        let submission = Submission.make(from: .make(
            attempt: 1,
            discussion_entries: [ .make(message: "<p>reply<p>") ]
        ))
        submission.assignment = Assignment.make(from: .make(is_quiz_lti_assignment: true))
        submission.type = .discussion_topic

        XCTAssertEqual(submission.attemptIcon, .quizLine)
        XCTAssertEqual(submission.attemptTitle, "Quiz")
        XCTAssertEqual(submission.attemptSubtitle, "Attempt 1")
    }

    func testRubricAssessments() {
        let submission = Submission.make(from: .make(rubric_assessment: [
            "A": .make(),
            "B": .make()
        ]))
        let assessA = RubricAssessment.make(id: "A")
        let assessB = RubricAssessment.make(id: "B")
        let map = submission.rubricAssessments ?? [:]
        XCTAssertEqual(map[assessA.id], assessA)
        XCTAssertEqual(map[assessB.id], assessB)
    }

    func testSaveRubricAssessmentsOnSubmission() {
        let assessmentItem = APIRubricAssessment.make()
        let item = APISubmission.make(rubric_assessment: ["1": assessmentItem])
        Submission.save(item, in: databaseClient)

        let assessments: [RubricAssessment] = databaseClient.fetch()
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.first?.rubricAssessments?["1"], assessments.first)
    }

    func testAttachmentsSorted() {
        let submission = Submission.make(from: .make(
            attachments: [
                .make(id: "42"),
                .make(id: "1"),
                .make(id: "3")
            ]
        ))

        XCTAssertEqual(submission.attachmentsSorted.map(\.id), ["1", "3", "42"])
    }

    func testSaveCommentAttachments() throws {
        let item = APISubmission.make(
            submission_comments: [
                APISubmissionComment.make(
                    attachments: [
                        APIFile.make(id: "1"),
                        APIFile.make(id: "2")
                    ]
                )
            ]
        )
        Submission.save(item, in: databaseClient)
        let submissions: [Submission] = databaseClient.fetch()
        let submission = submissions.first
        XCTAssertNotNil(submission)

        let comments: [SubmissionComment] = databaseClient.fetch()
        let comment = comments.first
        XCTAssertNotNil(comment)
        XCTAssertNotNil(comment?.assignmentID)
        XCTAssertNotNil(comment?.userID)
        XCTAssertEqual(comment?.assignmentID, submission?.assignmentID)
        XCTAssertEqual(comment?.userID, submission?.userID)
        let fileIDs = comment?.attachments?.map { $0.id }
        XCTAssertTrue(fileIDs?.contains("1") == true)
        XCTAssertTrue(fileIDs?.contains("2") == true)
    }

    func testSavesSubmissionHistory() {
        let item = APISubmission.make(
            attempt: 1,
            submission_history: [.make(attempt: 2)]
        )
        Submission.save(item, in: databaseClient)
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 2)
    }

    func testDoesNotSaveSubmissionHistoryWithNilAttempt() {
        let item = APISubmission.make(
            attempt: 1,
            submission_history: [.make(attempt: nil)]
        )
        Submission.save(item, in: databaseClient)
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)
    }

    func testNeedsGrading() {
        let nilType = Submission.make(from: .make(submission_type: nil))
        XCTAssertFalse(nilType.needsGrading)

        let pendingReview = Submission.make(from: .make(submission_type: .online_url, workflow_state: .pending_review))
        XCTAssertTrue(pendingReview.needsGrading)

        let gradedNoScore = Submission.make(from: .make(score: nil, submission_type: .online_url, workflow_state: .graded))
        XCTAssertTrue(gradedNoScore.needsGrading)

        let gradedScore = Submission.make(from: .make(score: 10, submission_type: .online_url, workflow_state: .graded))
        XCTAssertFalse(gradedScore.needsGrading)

        let submittedNoScore = Submission.make(from: .make(score: nil, submission_type: .online_url, workflow_state: .submitted))
        XCTAssertTrue(submittedNoScore.needsGrading)

        let submittedScore = Submission.make(from: .make(score: 10, submission_type: .online_url, workflow_state: .submitted))
        XCTAssertFalse(submittedScore.needsGrading)

        let regraded = Submission.make(from: .make(grade_matches_current_submission: false, score: 10, submission_type: .online_url, workflow_state: .graded))
        XCTAssertTrue(regraded.needsGrading)

        let resubmitted = Submission.make(from: .make(grade_matches_current_submission: false, score: 10, submission_type: .online_url, workflow_state: .submitted))
        XCTAssertTrue(resubmitted.needsGrading)
    }

    func testIsGraded() {
        let excused = Submission.make(from: .make(excused: true))
        XCTAssertTrue(excused.isGraded)

        let gradedNoScore = Submission.make(from: .make(score: nil, workflow_state: .graded))
        XCTAssertFalse(gradedNoScore.isGraded)

        let scoreNotGraded = Submission.make(from: .make(score: 10, workflow_state: .pending_review))
        XCTAssertFalse(scoreNotGraded.isGraded)

        let gradedWithScore = Submission.make(from: .make(score: 10, workflow_state: .graded))
        XCTAssertTrue(gradedWithScore.isGraded)
    }

    func testSubmissionStatus() {
        let late = Submission.make(from: .make(late: true))
        XCTAssertEqual(late.statusOld, .late)

        let missing = Submission.make(from: .make(missing: true))
        XCTAssertEqual(missing.statusOld, .missing)

        let submitted = Submission.make(from: .make(submitted_at: Date()))
        XCTAssertEqual(submitted.statusOld, .submitted)

        let notSubmitted = Submission.make(from: .make(late: false, missing: false, submitted_at: nil))
        XCTAssertEqual(notSubmitted.statusOld, .notSubmitted)

        let graded = Submission.make(from: .make(excused: false, score: 95, submitted_at: Date(), workflow_state: .graded))
        XCTAssertEqual(graded.statusIncludingGradedState, .graded)
        XCTAssertEqual(graded.statusOld, .submitted)
        XCTAssertEqual(graded.statusOld, graded.statusOld)

        let excused = Submission.make(from: .make(excused: true, score: 95, submitted_at: Date(), workflow_state: .graded))
        XCTAssertEqual(excused.statusIncludingGradedState, .excused)
        XCTAssertEqual(excused.statusOld, .submitted)
        XCTAssertEqual(excused.statusOld, excused.statusOld)
    }

    // MARK: - Checkpoints

    func test_saveHasSubAssignmentSubmissions() {
        // default should be false
        var item = APISubmission.make(has_sub_assignment_submissions: nil)
        var testee = saveModel(item)
        XCTAssertEqual(testee.hasSubAssignmentSubmissions, false)

        item = APISubmission.make(has_sub_assignment_submissions: true)
        testee = saveModel(item)
        XCTAssertEqual(testee.hasSubAssignmentSubmissions, true)

        // nil should not clear value
        item = APISubmission.make(has_sub_assignment_submissions: nil)
        testee = saveModel(item)
        XCTAssertEqual(testee.hasSubAssignmentSubmissions, true)

        item = APISubmission.make(has_sub_assignment_submissions: false)
        testee = saveModel(item)
        XCTAssertEqual(testee.hasSubAssignmentSubmissions, false)
    }

    func test_saveSubAssignmentSubmissions_whenNilOrEmpty() {
        var item = APISubmission.make(sub_assignment_submissions: nil)
        var testee = saveModel(item)
        XCTAssertEqual(testee.subAssignmentSubmissions.isEmpty, true)

        item = APISubmission.make(sub_assignment_submissions: [])
        testee = saveModel(item)
        XCTAssertEqual(testee.subAssignmentSubmissions.isEmpty, true)

        // set some value
        item = APISubmission.make(sub_assignment_submissions: [.make()])
        testee = saveModel(item)
        XCTAssertEqual(testee.subAssignmentSubmissions.isEmpty, false)

        // nil should not clear values
        item = APISubmission.make(sub_assignment_submissions: nil)
        testee = saveModel(item)
        XCTAssertEqual(testee.subAssignmentSubmissions.isEmpty, false)

        // [] should clear values
        item = APISubmission.make(sub_assignment_submissions: [])
        testee = saveModel(item)
        XCTAssertEqual(testee.subAssignmentSubmissions.isEmpty, true)
    }

    func test_saveSubAssignmentSubmissions_whenNotEmpty() {
        let item = APISubmission.make(
            id: "42",
            sub_assignment_submissions: [
                .make(sub_assignment_tag: "tag1"),
                .make(sub_assignment_tag: "tag2")
            ]
        )
        let testee = saveModel(item)

        let sortedSubSubmissions = testee.subAssignmentSubmissions.sorted(by: \.subAssignmentTag)
        XCTAssertEqual(sortedSubSubmissions.count, 2)
        XCTAssertEqual(sortedSubSubmissions.first?.subAssignmentTag, "tag1")
        XCTAssertEqual(sortedSubSubmissions.last?.subAssignmentTag, "tag2")

        let fetchedSubSubmissions: [CDSubAssignmentSubmission] = databaseClient
            .all(where: \.submissionId, equals: "42")
            .sorted(by: \.subAssignmentTag)
        XCTAssertEqual(fetchedSubSubmissions.count, 2)
        XCTAssertEqual(fetchedSubSubmissions.first?.subAssignmentTag, "tag1")
        XCTAssertEqual(fetchedSubSubmissions.last?.subAssignmentTag, "tag2")
    }

    // MARK: - Private Helpers

    private func saveModel(_ item: APISubmission) -> Submission {
        Submission.save(item, in: databaseClient)
    }
}
