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
import MobileCoreServices

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
        XCTAssertEqual(submissionTypes.allowedMediaTypes, [kUTTypeMovie as String, kUTTypeAudio as String])

        submissionTypes = [.media_recording, .online_upload]
        XCTAssertEqual(submissionTypes.allowedMediaTypes, [kUTTypeMovie as String, kUTTypeImage as String])
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
            .online_text_entry,
        ]
        let allowedExtensions = ["jpeg"]
        let result = submissionTypes.allowedUTIs(allowedExtensions: allowedExtensions)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains { $0.isImage })
        XCTAssertTrue(result.contains(.text))
    }
}
