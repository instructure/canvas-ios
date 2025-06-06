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
import MobileCoreServices
import XCTest
@testable import Core
import UniformTypeIdentifiers

class SubmissionTests: CoreTestCase {
    func testProperties() {
        let submission = Submission.make()

        submission.excused = nil
        XCTAssertNil(submission.excused)
        submission.excused = true
        XCTAssertEqual(submission.excused, true)

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
        XCTAssertEqual(late.status, .late)

        let missing = Submission.make(from: .make(missing: true))
        XCTAssertEqual(missing.status, .missing)

        let submitted = Submission.make(from: .make(submitted_at: Date()))
        XCTAssertEqual(submitted.status, .submitted)

        let notSubmitted = Submission.make(from: .make(late: false, missing: false, submitted_at: nil))
        XCTAssertEqual(notSubmitted.status, .notSubmitted)

        let graded = Submission.make(from: .make(excused: false, score: 95, submitted_at: Date(), workflow_state: .graded))
        XCTAssertEqual(graded.statusIncludingGradedState, .graded)
        XCTAssertEqual(graded.status, .submitted)
        XCTAssertEqual(graded.status, graded.status)

        let excused = Submission.make(from: .make(excused: true, score: 95, submitted_at: Date(), workflow_state: .graded))
        XCTAssertEqual(excused.statusIncludingGradedState, .excused)
        XCTAssertEqual(excused.status, .submitted)
        XCTAssertEqual(excused.status, excused.status)
    }

    func testSubmissionStateDisplayProperties() {
        let late = Submission.make(from: .make(late: true))
        XCTAssertEqual(late.stateDisplayProperties, .usingStatus(.late))

        let missing = Submission.make(from: .make(missing: true))
        XCTAssertEqual(missing.stateDisplayProperties, .usingStatus(.missing))

        let submitted = Submission.make(from: .make(submitted_at: Date()))
        submitted.typeRaw = SubmissionType.online_text_entry.rawValue
        XCTAssertEqual(submitted.stateDisplayProperties, .usingStatus(.submitted))

        let notSubmitted = Submission.make(from: .make(late: false, missing: false, submitted_at: nil))
        XCTAssertEqual(notSubmitted.stateDisplayProperties, .usingStatus(.notSubmitted))

        // No Submission
        let assignment = Assignment.make()
        assignment.submissionTypes = [.none]

        let noSubmission = Submission.make(from: .make(late: false, missing: false, submitted_at: nil))
        noSubmission.assignment = assignment

        XCTAssertEqual(noSubmission.stateDisplayProperties, .noSubmission)

        // On Paper Submission
        assignment.submissionTypes = [.on_paper]

        let onPaperSubmission = Submission.make(from: .make(late: false, missing: false, submitted_at: nil))
        onPaperSubmission.assignment = assignment

        XCTAssertEqual(onPaperSubmission.stateDisplayProperties, .onPaper)

        // On Paper/Graded Submission
        assignment.submissionTypes = [.on_paper]

        let onPaperGradedSubmission = Submission.make(from: .make(late: false, missing: false, submitted_at: nil))
        onPaperGradedSubmission.score = 7
        onPaperGradedSubmission.workflowState = .graded
        onPaperGradedSubmission.assignment = assignment

        XCTAssertEqual(onPaperGradedSubmission.stateDisplayProperties, .graded)
    }
}

class SubmissionTypeTests: XCTestCase {
    func testInitRawValue() {
        // Converting to & from String is needed by database models
        XCTAssertEqual(SubmissionType(rawValue: "discussion_topic"), .discussion_topic)
        XCTAssertEqual(SubmissionType.discussion_topic.rawValue, "discussion_topic")
    }

    func testLocalizedString() {
        XCTAssertEqual(SubmissionType.discussion_topic.localizedString, "Discussion Comment")
        XCTAssertEqual(SubmissionType.external_tool.localizedString, "External Tool")
        XCTAssertEqual(SubmissionType.media_recording.localizedString, "Media Recording")
        XCTAssertEqual(SubmissionType.none.localizedString, "No Submission")
        XCTAssertEqual(SubmissionType.not_graded.localizedString, "Not Graded")
        XCTAssertEqual(SubmissionType.online_quiz.localizedString, "Quiz")
        XCTAssertEqual(SubmissionType.online_text_entry.localizedString, "Text Entry")
        XCTAssertEqual(SubmissionType.online_upload.localizedString, "File Upload")
        XCTAssertEqual(SubmissionType.online_url.localizedString, "Website URL")
        XCTAssertEqual(SubmissionType.on_paper.localizedString, "On Paper")
    }

    func testAllowedMediaTypesForMediaRecordings() {
        var submissionTypes: [SubmissionType] = [.media_recording]
        XCTAssertEqual(submissionTypes.allowedMediaTypes, [UTType.movie.identifier, UTType.audio.identifier])

        submissionTypes = [.media_recording, .online_upload]
        XCTAssertEqual(submissionTypes.allowedMediaTypes, [UTType.movie.identifier, UTType.image.identifier])
    }

    func testAllowedUTIsNoneIsEmpty() {
        let submissionTypes: [SubmissionType] = [.none]
        let r = submissionTypes.allowedUTIs( allowedExtensions: ["png"] )
        XCTAssertTrue(r.isEmpty)
    }

    func testAllowedUTIsAny() {

        let submissionTypes: [SubmissionType] = [.online_upload]

        XCTAssertEqual(submissionTypes.allowedUTIs(allowedExtensions: []), [.any])
    }

    func testAllowedUTIsAllowedExtensions() {
        let submissionTypes: [SubmissionType] = [.online_upload]
        let allowedExtensions = ["png", "mov", "mp3"]
        let result = submissionTypes.allowedUTIs(allowedExtensions: allowedExtensions)
        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result.contains { $0.isImage })
        XCTAssertTrue(result.contains { $0.isVideo })
        XCTAssertTrue(result.contains { $0.isAudio })
    }

    func testAllowedUTIsAllowedExtensionsVideo() {
        let submissionTypes: [SubmissionType] = [.online_upload]
        let allowedExtensions = ["mov", "mp4"]
        let result = submissionTypes.allowedUTIs(allowedExtensions: allowedExtensions)
        XCTAssertTrue(result[0].isVideo)
        XCTAssertTrue(result[1].isVideo)
    }

    func testAllowedUTIsMediaRecording() {
        let submissionTypes: [SubmissionType] = [.media_recording]
        let result = submissionTypes.allowedUTIs(allowedExtensions: [])
        XCTAssertTrue(result.contains(.video))
        XCTAssertTrue(result.contains(.audio))
    }

    func testAllowedUTIsText() {
        let submissionTypes: [SubmissionType] = [.online_text_entry]
        XCTAssertEqual(submissionTypes.allowedUTIs(allowedExtensions: []), [.text])
    }

    func testAllowedUTIsURL() {
        let submissionTypes: [SubmissionType] = [.online_url]
        XCTAssertEqual(submissionTypes.allowedUTIs(allowedExtensions: []), [.url])
    }

    func testAllowedUTIsMultipleSubmissionTypes() {
        let submissionTypes: [SubmissionType] = [
            .online_upload,
            .online_text_entry
        ]
        let allowedExtensions = ["jpeg"]
        let result = submissionTypes.allowedUTIs(allowedExtensions: allowedExtensions)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains { $0.isImage })
        XCTAssertTrue(result.contains(.text))
    }

    func testStudioSubmissionTypes() {
        // The strange format is to make sure all cases are tested
        for submissionType in SubmissionType.allCases {
            switch submissionType {
            case .discussion_topic,
                 .none,
                 .not_graded,
                 .online_quiz,
                 .online_text_entry,
                 .on_paper,
                 .wiki_page,
                 .student_annotation,
                 .online_url,
                 .media_recording,
                 .basic_lti_launch,
                 .external_tool:
                let result = [submissionType].isStudioAccepted(allowedExtensions: [])
                XCTAssertEqual(result, false)
            case .online_upload:
                let acceptedFileExtensions = ["mp4", "mov", "avi"]

                for acceptedFileExtension in acceptedFileExtensions {
                    let result = [submissionType].isStudioAccepted(
                        allowedExtensions: [acceptedFileExtension]
                    )
                    XCTAssertEqual(result, true)
                }

                let notAcceptedFileExtensions = ["pdf", "docx", "txt"]

                for notAcceptedFileExtension in notAcceptedFileExtensions {
                    let result = [submissionType].isStudioAccepted(
                        allowedExtensions: [notAcceptedFileExtension]
                    )
                    XCTAssertEqual(result, false)
                }

                let noFileExtensionRestriction: [String] = []
                let result = [submissionType].isStudioAccepted(
                    allowedExtensions: noFileExtensionRestriction
                )
                XCTAssertEqual(result, true)
            }
        }
    }

}
