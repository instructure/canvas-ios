//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import UniformTypeIdentifiers
import XCTest
@testable import Core

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
        let allowedExtensions = ["png", "mov", "mp3", "pdf"]
        let result = submissionTypes.allowedUTIs(allowedExtensions: allowedExtensions)
        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result.contains { $0.isImage })
        XCTAssertTrue(result.contains { $0.isVideo })
        XCTAssertTrue(result.contains { $0.isAudio })
        XCTAssertTrue(result.contains { $0.isPDF })
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
