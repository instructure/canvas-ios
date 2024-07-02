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

import XCTest
@testable import Core
@testable import TestsFoundation

class ConferenceDetailsViewControllerTests: CoreTestCase {

    private enum TestConstants {
        static let date = DateComponents(calendar: .current, year: 2020, month: 3, day: 14).date!
    }

    let course1 = Context(.course, id: "1")
    var conferenceID = "1"
    lazy var controller = ConferenceDetailsViewController.create(context: course1, conferenceID: conferenceID)

    override func setUp() {
        super.setUp()
        Clock.mockNow(TestConstants.date)
        api.mock(controller.colors, value: APICustomColors(custom_colors: [ "course_1": "#f00" ]))
        api.mock(controller.course, value: .make())
        api.mock(controller.conferences, value: GetConferencesRequest.Response(conferences: [
            .make(
                description: """
                We're getting together to play the board game Pandemic, since we are stuck in quarantine anyway.
                """,
                id: "1",
                title: "Pandemic playthrough"
            )
        ]))
    }

    override func tearDown() {
        Clock.reset()
        super.tearDown()
    }

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.titleSubtitleView.title, "Conference Details")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")
        XCTAssertEqual(nav.navigationBar.barTintColor!.hexString, UIColor(hexString: "#f00")!.darkenToEnsureContrast(against: .white).hexString)

        XCTAssertEqual(controller.titleLabel.text, "Pandemic playthrough")
        XCTAssertEqual(controller.statusLabel.text, "Not Started")
        XCTAssertEqual(controller.detailsLabel.text, """
        We're getting together to play the board game Pandemic, since we are stuck in quarantine anyway.
        """)
        XCTAssertEqual(controller.joinButton.isHidden, true)
        XCTAssertEqual(controller.recordingsView.isHidden, true)

        api.mock(controller.conferences, value: .init(conferences: [ .make(description: "", started_at: Clock.now) ]))
        controller.refreshControl.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.statusLabel.text, "In Progress | Started " + TestConstants.date.dateTimeString)
        XCTAssertEqual(controller.detailsLabel.text, "No description")
        XCTAssertEqual(controller.joinButton.isHidden, false)
        XCTAssertEqual(controller.recordingsView.isHidden, true)

        controller.joinButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.lastRoutedTo(.parse("courses/1/conferences/1/join")))

        api.mock(controller.conferences, value: .init(conferences: [
            .make(description: "", ended_at: Clock.now, recordings: [ .make(
                created_at: Clock.now,
                duration_minutes: 65,
                playback_formats: [ .make(length: "", type: "video", url: URL(string: "/playback")!) ],
                playback_url: nil,
                title: "Recording 1"
            ) ])
        ]))
        controller.refreshControl.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.statusLabel.text, "Concluded " + TestConstants.date.dateTimeString)
        XCTAssertEqual(controller.joinButton.isHidden, true)
        XCTAssertEqual(controller.recordingsView.isHidden, false)

        let index0 = IndexPath(row: 0, section: 0)
        let cell0 = controller.tableView.cellForRow(at: index0) as? ConferenceRecordingCell
        XCTAssertEqual(cell0?.titleLabel.text, "Recording 1")
        XCTAssertEqual(cell0?.dateLabel.text, TestConstants.date.dateTimeString)
        XCTAssertEqual(cell0?.durationLabel.text, "1 hour, 5 minutes")

        controller.tableView.selectRow(at: index0, animated: false, scrollPosition: .none)
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index0)
        XCTAssert(router.lastRoutedTo(.parse("https://canvas.instructure.com/playback")))
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)
    }

    func testConferenceWithStatistics() {
        api.mock(controller.conferences, value: .init(conferences: [
            .make(id: conferenceID, recordings: [
                .make(
                    playback_formats: [
                        .make(type: "statistics", url: URL(string: "/statistics")!),
                        .make(type: "video", url: URL(string: "/playback")!)
                    ],
                    playback_url: nil
                )
            ])
        ]))
        controller.view.layoutIfNeeded()
        let index0 = IndexPath(row: 0, section: 0)
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index0)
        XCTAssert(router.lastRoutedTo(.parse("https://canvas.instructure.com/playback")))
    }
}
