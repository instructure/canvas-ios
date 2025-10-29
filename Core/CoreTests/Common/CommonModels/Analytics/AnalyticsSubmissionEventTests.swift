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

class AnalyticsSubmissionEventTests: XCTestCase {
    private var testAnalyticsHandler: MockAnalyticsHandler!

    override func setUp() {
        super.setUp()
        testAnalyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = testAnalyticsHandler
    }

    func testLogSingleEvents() {
        Analytics.shared.logSubmission(.start)
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "assignment_submit_selected")

        Analytics.shared.logSubmission(.lti)
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "assignment_launchlti_selected")
    }

    func testLogPhasedEvents() {
        Analytics.shared.logSubmission(.phase(.selected, .text_entry, 3))
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "submit_textentry_selected")
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("attempt"), 3)

        Analytics.shared.logSubmission(.phase(.succeeded, .url, 2))
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "submit_url_succeeded")
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("attempt"), 2)

        Analytics.shared.logSubmission(
            .phase(.failed, .file_upload, nil),
            additionalParams: [.error: "Random error desc"]
        )
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "submit_fileupload_failed")
        XCTAssertNil(testAnalyticsHandler.lastEventParameter("attempt", ofType: Int.self))
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("error"), "Random error desc")

        Analytics.shared.logSubmission(
            .phase(.failed, .media_recording, 10),
            additionalParams: [.media_type: "video", .media_source: "camera"]
        )
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "submit_mediarecording_failed")
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("attempt"), 10)
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("media_source"), "camera")
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("media_type"), "video")

        Analytics.shared.logSubmission(.phase(.presented, .annotation, nil))
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "submit_annotation_presented")

        Analytics.shared.logSubmission(.phase(.selected, .studio, 2))
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "submit_studio_selected")
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("attempt"), 2)
    }

    func testLogDetailEvents() {
        Analytics.shared.logSubmission(.detail(.discussion))
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "assignment_detail_discussionlaunch")

        Analytics.shared.logSubmission(.detail(.quiz))
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "assignment_detail_quizlaunch")
    }
}
