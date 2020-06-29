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
@testable import Student
@testable import Core
import TestsFoundation

class CalendarEventItemDetailsViewControllerTests: StudentTestCase {
    lazy var controller = CalendarEventItemDetailsViewController.create(eventID: "1")

    override func setUp() {
        super.setUp()
        api.mock(controller.colors, value: .init(custom_colors: [
            "user_1": "#ff0000",
            "course_1": "#0000ff",
        ]))
        api.mock(controller.events, value: .make(
            start_at: DateComponents(calendar: .current, year: 2020, month: 6, day: 24).date,
            all_day: true,
            description: "description"
        ))
    }

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, "#0000ff")
        XCTAssertEqual(controller.titleSubtitleView.title, "Event Details")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")
        XCTAssertEqual(controller.titleLabel.text, "calendar event #1")
        XCTAssertEqual(controller.dateLabel.text, "Jun 24, 2020")
        XCTAssertEqual(controller.locationView.isHidden, true)

        api.mock(controller.events, value: .make(
            start_at: DateComponents(calendar: .current, year: 2020, month: 6, day: 24, hour: 11).date,
            end_at: DateComponents(calendar: .current, year: 2020, month: 6, day: 24, hour: 13).date,
            context_code: "user_1",
            context_name: "Bob",
            location_name: "School",
            location_address: "place"
        ))
        controller.scrollView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, "#ff0000")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Bob")
        XCTAssertEqual(controller.locationView.isHidden, false)
        XCTAssertEqual(controller.dateLabel.text, "Jun 24, 2020, 11:00 AM – 1:00 PM")
        XCTAssertEqual(controller.locationNameLabel.text, "School")
        XCTAssertEqual(controller.locationAddressLabel.text, "place")

        api.mock(controller.events, value: .make(
            start_at: DateComponents(calendar: .current, year: 2020, month: 6, day: 24, hour: 11).date,
            end_at: nil,
            context_code: "group_1"
        ))
        controller.scrollView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(nav.navigationBar.barTintColor, .named(.ash))
        XCTAssertEqual(controller.dateLabel.text, "Jun 24, 2020 at 11:00 AM")
    }
}
