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
}
