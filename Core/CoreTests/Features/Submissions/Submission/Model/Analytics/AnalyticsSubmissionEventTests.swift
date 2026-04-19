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

import XCTest
@testable import Core
import TestsFoundation

class AnalyticsSubmissionEventTests: CoreTestCase {

    func testLogSingleEvents() {
        Analytics.shared.logSubmission(.start)
        XCTAssertEqual(analytics.handleEventInput?.name, "assignmentDetails_submitButton_selected")
    }

    func testLogPhasedEvents() {
        Analytics.shared.logSubmission(.phase(.selected, .textEntry, 3))
        XCTAssertEqual(analytics.handleEventInput?.name, "submit_textEntry_selected")
        XCTAssertEqual(analytics.handleEventInput?.parameters?["attempt"] as? Int, 3)

        Analytics.shared.logSubmission(.phase(.succeeded, .url, 2))
        XCTAssertEqual(analytics.handleEventInput?.name, "submit_url_succeeded")
        XCTAssertEqual(analytics.handleEventInput?.parameters?["attempt"] as? Int, 2)

        Analytics.shared.logSubmission(
            .phase(.failed, .fileUpload, nil),
            additionalParams: [.retry: 1, .error: "Random error desc"]
        )
        XCTAssertEqual(analytics.handleEventInput?.name, "submit_fileUpload_failed")
        XCTAssertNil(analytics.handleEventInput?.parameters?["attempt"] as? Int)
        XCTAssertEqual(analytics.handleEventInput?.parameters?["error"] as? String, "Random error desc")
        XCTAssertEqual(analytics.handleEventInput?.parameters?["retry"] as? Int, 1)

        Analytics.shared.logSubmission(
            .phase(.failed, .mediaRecording, 10),
            additionalParams: [.media_type: "video", .media_source: "camera"]
        )
        XCTAssertEqual(analytics.handleEventInput?.name, "submit_mediaRecording_failed")
        XCTAssertEqual(analytics.handleEventInput?.parameters?["attempt"] as? Int, 10)
        XCTAssertEqual(analytics.handleEventInput?.parameters?["media_source"] as? String, "camera")
        XCTAssertEqual(analytics.handleEventInput?.parameters?["media_type"] as? String, "video")

        Analytics.shared.logSubmission(.phase(.presented, .annotation, nil))
        XCTAssertEqual(analytics.handleEventInput?.name, "submit_annotation_presented")

        Analytics.shared.logSubmission(.phase(.selected, .studio, 2))
        XCTAssertEqual(analytics.handleEventInput?.name, "submit_studio_selected")
        XCTAssertEqual(analytics.handleEventInput?.parameters?["attempt"] as? Int, 2)
    }

    func testLogDetailEvents() {
        Analytics.shared.logSubmission(.detail(.discussion))
        XCTAssertEqual(analytics.handleEventInput?.name, "assignmentDetails_discussion_opened")

        Analytics.shared.logSubmission(.detail(.classicQuiz))
        XCTAssertEqual(analytics.handleEventInput?.name, "assignmentDetails_classicQuiz_opened")

        Analytics.shared.logSubmission(.detail(.newQuiz))
        XCTAssertEqual(analytics.handleEventInput?.name, "assignmentDetails_newQuiz_opened")

        Analytics.shared.logSubmission(.detail(.lti))
        XCTAssertEqual(analytics.handleEventInput?.name, "assignmentDetails_lti_opened")
    }
}
