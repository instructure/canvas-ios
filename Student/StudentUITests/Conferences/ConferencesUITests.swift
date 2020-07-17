//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import TestsFoundation
@testable import Core

class ConferencesUITests: MiniCanvasUITestCase {
    let date = Date(timeIntervalSinceReferenceDate: 0)
    lazy var liveConference = APIConference.make(context_type: "Course", started_at: date)

    override func setUpState() {
        super.setUpState()
        mocked.liveConferences = [ liveConference ]
        MiniCanvasServer.shared.server.logResponses = true
    }

    func testConcludedConferenceDetails() {
        let date = Date(timeIntervalSinceReferenceDate: 0)
        let recording = APIConferenceRecording.make(created_at: date)
        let conference = APIConference.make(
            ended_at: date,
            recordings: [recording]
        )
        firstCourse.conferences = [conference]
        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.conferences.tap()
        ConferencesList.Cell(id: conference.id.value).title.tap()

        XCTAssertEqual(ConferenceDetails.title.label(), conference.title)
        XCTAssert(ConferenceDetails.status.label().starts(with: "Concluded "))
        XCTAssertEqual(ConferenceDetails.details.label(), conference.description)

        XCTAssertEqual(ConferenceDetails.Recording.title.label(), recording.title)
        XCTAssertFalse(ConferenceDetails.Recording.date.label().isEmpty)
        XCTAssertEqual(ConferenceDetails.Recording.duration.label(), "1 hour")
    }

    func testDashboardLiveConference() {
        XCTAssertEqual(
            app.find(id: "LiveConference.1.navigateButton").label(),
            "Conference test conference is in progress, tap to view details"
        )
        app.find(id: "LiveConference.1.dismissButton").tap().waitToVanish()
    }
}
