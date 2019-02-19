//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Core

class SubmissionViewableTests: XCTestCase {
    struct Model: SubmissionViewable {
        let submission: Submission?
        let submissionTypes: [SubmissionType]
        let allowedExtensions: [String]
        let fileSubmission: FileSubmission?

        init(
            submission: Submission? = Submission.make(),
            submissionTypes: [SubmissionType] = [.online_text_entry],
            allowedExtensions: [String] = [],
            fileSubmission: FileSubmission? = nil
        ) {
            self.submission = submission
            self.submissionTypes = submissionTypes
            self.allowedExtensions = allowedExtensions
            self.fileSubmission = fileSubmission
        }
    }

    func testHasFileTypes() {
        XCTAssertFalse(Model(submissionTypes: [.none], allowedExtensions: []).hasFileTypes)
        XCTAssertFalse(Model(submissionTypes: [.none], allowedExtensions: ["pdf"]).hasFileTypes)
        XCTAssertFalse(Model(submissionTypes: [.online_upload], allowedExtensions: []).hasFileTypes)
        XCTAssertTrue(Model(submissionTypes: [.online_upload], allowedExtensions: ["pdf"]).hasFileTypes)
    }

    func testFileTypeText() {
        XCTAssertNil(Model(allowedExtensions: []).fileTypeText)
        XCTAssertEqual(Model(submissionTypes: [.online_upload], allowedExtensions: ["a", "b", "c"]).fileTypeText, "a, b, or c")
    }

    func testSubmissionTypeText() {
        let assignment = Model(submissionTypes: [ .discussion_topic, .online_quiz, .on_paper, .none, .external_tool, .online_text_entry, .online_url, .online_upload, .media_recording, .not_graded ])
        XCTAssertEqual(assignment.submissionTypeText, "Discussion Comment, Quiz, On Paper, No Submission, External Tool, Text Entry, Website URL, File Upload, Media Recording, or Not Graded")
    }

    func testIsSubmitted() {
        XCTAssertFalse(Model(submission: nil).isSubmitted)
        XCTAssertFalse(Model(submission: Submission.make(["workflowStateRaw": "unsubmitted"])).isSubmitted)
        XCTAssertTrue(Model(submission: Submission.make(["workflowStateRaw": "submitted"])).isSubmitted)
    }

    func testStatusIsHidden() {
        XCTAssertFalse(Model(submissionTypes: [.online_text_entry]).submissionStatusIsHidden)
        XCTAssertTrue(Model(submissionTypes: [.none]).submissionStatusIsHidden)
        XCTAssertTrue(Model(submissionTypes: [.not_graded]).submissionStatusIsHidden)
    }

    func testStatusColor() {
        XCTAssertEqual(Model(submission: nil).submissionStatusColor, UIColor.named(.ash))
        XCTAssertEqual(Model(submission: Submission.make(["workflowStateRaw": "submitted"])).submissionStatusColor, UIColor.named(.shamrock))
    }

    func testStatusIcon() {
        XCTAssertEqual(Model(submission: nil).submissionStatusIcon, UIImage.icon(.no, .solid))
        XCTAssertEqual(Model(submission: Submission.make(["workflowStateRaw": "submitted"])).submissionStatusIcon, UIImage.icon(.complete, .solid))
    }

    func testStatusText() {
        XCTAssertEqual(Model(submission: nil).submissionStatusText, "Not Submitted")
        XCTAssertEqual(Model(submission: Submission.make(["workflowStateRaw": "submitted"])).submissionStatusText, "Submitted")
        let submittedAt = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 1).date!
        XCTAssertEqual(Model(submission: Submission.make(["workflowStateRaw": "submitted", "submittedAt": submittedAt])).submissionStatusText, "Submitted Oct 1, 2018 at 12:00 AM")
    }

    func testHasLatePenalty() {
        XCTAssertFalse(Model(submission: nil).hasLatePenalty)
        XCTAssertFalse(Model(submission: Submission.make([ "late": true ])).hasLatePenalty)
        XCTAssertFalse(Model(submission: Submission.make([ "pointsDeductedRaw": 0, "late": true ])).hasLatePenalty)
        XCTAssertTrue(Model(submission: Submission.make([ "pointsDeductedRaw": 10, "late": true ])).hasLatePenalty)
    }

    func testLatePenaltyText() {
        XCTAssertNil(Model(submission: nil).latePenaltyText)
        XCTAssertNil(Model(submission: Submission.make([ "late": false ])).latePenaltyText)
        XCTAssertNil(Model(submission: Submission.make([ "late": true ])).latePenaltyText)
        XCTAssertEqual(Model(submission: Submission.make([ "late": true, "pointsDeductedRaw": 10 ])).latePenaltyText, "Late penalty (-10 pts)")
        XCTAssertEqual(Model(submission: Submission.make([ "late": true, "pointsDeductedRaw": 1 ])).latePenaltyText, "Late penalty (-1 pt)")
    }

    func testIsSubmittable() {
        XCTAssertTrue(Model(submissionTypes: [.online_text_entry]).isSubmittable)
        XCTAssertFalse(Model(submissionTypes: [.none]).isSubmittable)
    }

    func testShowFileSubmissionStatusTrue() {
        let model = Model(fileSubmission: FileSubmission.make(["submitted": false]))
        XCTAssertTrue(model.showFileSubmissionStatus)
    }

    func testShowFileSubmissionStatusFalseNoFileSubmission() {
        let model = Model(fileSubmission: nil)
        XCTAssertFalse(model.showFileSubmissionStatus)
    }

    func testShowFileSubmissionStatusFalseSubmitted() {
        let model = Model(fileSubmission: FileSubmission.make(["submitted": true]))
        XCTAssertFalse(model.showFileSubmissionStatus)
    }

    func testFileSubmissionStatusTextNil() {
        let model = Model(fileSubmission: nil)
        XCTAssertNil(model.fileSubmissionStatusText)
    }

    func testFileSubmissionStatusTextFailed() {
        let model = Model(fileSubmission: FileSubmission.make(["error": "error"]))
        XCTAssertEqual(model.fileSubmissionStatusText, "Submission Failed")
    }

    func testFileSubmissionStatusTextUploading() {
        let model = Model(fileSubmission: FileSubmission.make(["error": nil]))
        XCTAssertEqual(model.fileSubmissionStatusText, "Submission Uploading...")
    }

    func testFileSubmissionStatusTextColorNil() {
        let model = Model(fileSubmission: nil)
        XCTAssertNil(model.fileSubmissionStatusTextColor)
    }

    func testFileSubmissionStatusTextColorFailed() {
        let model = Model(fileSubmission: FileSubmission.make(["error": "error"]))
        XCTAssertEqual(model.fileSubmissionStatusTextColor, UIColor.named(.textDanger))
    }

    func testFileSubmissionStatusTextColorUploading() {
        let model = Model(fileSubmission: FileSubmission.make(["error": nil]))
        XCTAssertEqual(model.fileSubmissionStatusTextColor, UIColor.named(.textSuccess))
    }

    func testFileSubmissionStatusButtonTextNil() {
        let model = Model(fileSubmission: nil)
        XCTAssertNil(model.fileSubmissionButtonText)
    }

    func testFileSubmissionStatusButtonTextFailed() {
        let model = Model(fileSubmission: FileSubmission.make(["error": "error"]))
        XCTAssertEqual(model.fileSubmissionButtonText, "Tap to view details")
    }

    func testFileSubmissionStatusButtonTextUploading() {
        let model = Model(fileSubmission: FileSubmission.make(["error": nil]))
        XCTAssertEqual(model.fileSubmissionButtonText, "Tap to view progress")
    }
}
