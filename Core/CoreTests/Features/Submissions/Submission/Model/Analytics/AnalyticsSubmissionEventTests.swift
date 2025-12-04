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
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "assignmentDetails_submitButton_selected")
    }

    func testLogPhasedEvents() {
        Analytics.shared.logSubmission(.phase(.selected, .textEntry, 3))
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "submit_textEntry_selected")
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("attempt"), 3)

        Analytics.shared.logSubmission(.phase(.succeeded, .url, 2))
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "submit_url_succeeded")
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("attempt"), 2)

        Analytics.shared.logSubmission(
            .phase(.failed, .fileUpload, nil),
            additionalParams: [.retry: 1, .error: "Random error desc"]
        )
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "submit_fileUpload_failed")
        XCTAssertNil(testAnalyticsHandler.lastEventParameter("attempt", ofType: Int.self))
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("error"), "Random error desc")
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("retry"), 1)

        Analytics.shared.logSubmission(
            .phase(.failed, .mediaRecording, 10),
            additionalParams: [.media_type: "video", .media_source: "camera"]
        )
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "submit_mediaRecording_failed")
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
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "assignmentDetails_discussion_opened")

        Analytics.shared.logSubmission(.detail(.classicQuiz))
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "assignmentDetails_classicQuiz_opened")

        Analytics.shared.logSubmission(.detail(.newQuiz))
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "assignmentDetails_newQuiz_opened")

        Analytics.shared.logSubmission(.detail(.lti))
        XCTAssertEqual(testAnalyticsHandler.lastEvent, "assignmentDetails_lti_opened")
    }
}
