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

class SubmissionViewableTests: XCTestCase {
    struct Model: SubmissionViewable {
        let submission: Submission?
        let submissionTypes: [SubmissionType]
        let allowedExtensions: [String]

        init(
            submission: Submission? = Submission.make(),
            submissionTypes: [SubmissionType] = [.online_text_entry],
            allowedExtensions: [String] = []
        ) {
            self.submission = submission
            self.submissionTypes = submissionTypes
            self.allowedExtensions = allowedExtensions
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
        XCTAssertFalse(Model(submission: Submission.make(from: .make(submitted_at: nil))).isSubmitted)
        XCTAssertTrue(Model(submission: Submission.make(from: .make(submitted_at: Date()))).isSubmitted)
    }

    func testStatusIsHidden() {
        XCTAssertFalse(Model(submissionTypes: [.online_text_entry]).submissionStatusIsHidden)
        XCTAssertTrue(Model(submissionTypes: [.not_graded]).submissionStatusIsHidden)
    }

    func testStatusColor() {
        XCTAssertEqual(Model(submission: nil).submissionStatusColor, UIColor.textDark)
        XCTAssertEqual(Model(submission: Submission.make(from: .make(submitted_at: Date()))).submissionStatusColor, UIColor.textSuccess)
    }

    func testStatusIcon() {
        XCTAssertEqual(Model(submission: nil).submissionStatusIcon, UIImage.noSolid)
        XCTAssertEqual(Model(submission: Submission.make(from: .make(submitted_at: Date()))).submissionStatusIcon, UIImage.completeSolid)
    }

    func testStatusText() {
        XCTAssertEqual(Model(submission: nil).submissionStatusText, "Not Submitted")
        let submittedAt = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 1).date!
        XCTAssertEqual(Model(submission: Submission.make(from: .make(submitted_at: submittedAt))).submissionStatusText, "Submitted")
        XCTAssertEqual(Model(submission: Submission.make(from: .make(submitted_at: submittedAt, workflow_state: .graded))).submissionStatusText, "Graded")
    }

    func testSubmissionDateText() {
        XCTAssertNil(Model(submission: nil).submissionDateText)
        let submittedAt = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 1).date!
        XCTAssertEqual(Model(submission: Submission.make(from: .make(submitted_at: submittedAt))).submissionDateText, submittedAt.dateTimeString)
    }

    func testHasLatePenalty() {
        XCTAssertFalse(Model(submission: nil).hasLatePenalty)
        XCTAssertFalse(Model(submission: Submission.make(from: .make(late: true))).hasLatePenalty)
        XCTAssertFalse(Model(submission: Submission.make(from: .make(late: true, points_deducted: 0 ))).hasLatePenalty)
        XCTAssertTrue(Model(submission: Submission.make(from: .make(late: true, points_deducted: 10 ))).hasLatePenalty)
    }

    func testLatePenaltyText() {
        XCTAssertNil(Model(submission: nil).latePenaltyText)
        XCTAssertNil(Model(submission: Submission.make(from: .make(late: false))).latePenaltyText)
        XCTAssertNil(Model(submission: Submission.make(from: .make(late: true))).latePenaltyText)
        XCTAssertEqual(Model(submission: Submission.make(from: .make(late: true, points_deducted: 10 ))).latePenaltyText, "Late Penalty: -10 pts")
        XCTAssertEqual(Model(submission: Submission.make(from: .make(late: true, points_deducted: 1 ))).latePenaltyText, "Late Penalty: -1 pt")
    }

    func testIsSubmittable() {
        XCTAssertTrue(Model(submissionTypes: [.online_text_entry]).isSubmittable)
        XCTAssertFalse(Model(submissionTypes: [.none]).isSubmittable)
        XCTAssertFalse(Model(submissionTypes: [.not_graded]).isSubmittable)
    }
}
