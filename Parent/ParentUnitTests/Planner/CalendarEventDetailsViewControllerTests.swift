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
@testable import Parent
import TestsFoundation

class CalendarEventDetailsViewControllerTests: ParentTestCase {
    lazy var controller = CalendarEventDetailsViewController.create(studentID: "1", eventID: "1")

    override func setUp() {
        super.setUp()
        api.mock(controller.events, value: .make(
            id: "1",
            title: "It's happening",
            start_at: DateComponents(calendar: .current, year: 2020, month: 7, day: 14).date,
            end_at: nil,
            all_day: true,
            description: "This test is written",
            location_name: "Instructure Inc",
            location_address: "6330 S 3000 E Unit 700\nSalt Lake City, UT 84121"
        ))
    }

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, ColorScheme.observee("1").color.ensureContrast(against: .white).hexString)
        XCTAssertEqual(controller.titleSubtitleView.title, "Course One")
        XCTAssertEqual(controller.titleLabel.text, "It's happening")
        XCTAssertEqual(controller.dateLabel.text, "Jul 14, 2020")
        XCTAssertEqual(controller.locationView.isHidden, false)
        XCTAssertEqual(controller.locationNameLabel.text, "Instructure Inc")
        XCTAssertEqual(controller.locationAddressLabel.text, "6330 S 3000 E Unit 700\nSalt Lake City, UT 84121")
        XCTAssertEqual(controller.reminderHeadingLabel.text, "Remind Me")
        XCTAssertEqual(controller.reminderMessageLabel.text, "Set a date and time to be notified of this event.")
        XCTAssertEqual(controller.reminderSwitch.isOn, false)
        XCTAssertEqual(controller.reminderDateButton.isHidden, true)
        XCTAssertFalse(router.presented is CoreHostingController<CoreDatePickerActionSheetCard>)

        api.mock(controller.events, value: .make(
            id: "1",
            start_at: DateComponents(calendar: .current, year: 2020, month: 7, day: 14, hour: 10).date,
            end_at: DateComponents(calendar: .current, year: 2020, month: 7, day: 14, hour: 12).date,
            all_day: false
        ))
        controller.scrollView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.dateLabel.text, "Jul 14, 2020, 10:00 AM – 12:00 PM")
        XCTAssertEqual(controller.locationView.isHidden, true)

        api.mock(controller.events, value: .make(
            id: "1",
            start_at: DateComponents(calendar: .current, year: 2020, month: 7, day: 14, hour: 10).date,
            end_at: nil,
            all_day: false
        ))
        controller.scrollView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.dateLabel.text, "Jul 14, 2020 at 10:00 AM")
    }

    func testReminder() {
        let prev = Clock.now.startOfDay().addDays(1)
        notificationManager.setReminder(id: "1", content: UNMutableNotificationContent(), at: prev) { _ in }
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.reminderHeadingLabel.text, "Remind Me")
        XCTAssertEqual(controller.reminderMessageLabel.text, "Set a date and time to be notified of this event.")
        XCTAssertEqual(controller.reminderSwitch.isOn, true)
        XCTAssertEqual(controller.reminderDateButton.isHidden, false)
        XCTAssertEqual(controller.reminderDateButton.title(for: .normal), prev.dateTimeString)
        XCTAssertNil(router.presented)

        controller.reminderDateButton.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(router.presented is CoreHostingController<CoreDatePickerActionSheetCard>)
        XCTAssertEqual(controller.selectedDate, prev)

        controller.reminderDateChanged(selectedDate: prev.addDays(1))
        notificationManager.getReminder("1") { request in
            let date = (request?.trigger as? UNCalendarNotificationTrigger).flatMap {
                Calendar.current.date(from: $0.dateComponents)
            }
            XCTAssertEqual(date, prev.addDays(1))
        }
        notificationCenter.error = NSError.internalError()
        controller.reminderDateChanged(selectedDate: controller.selectedDate)
        XCTAssertEqual(controller.reminderSwitch.isOn, false)

        notificationCenter.authorized = false
        controller.reminderSwitch.isOn = true
        controller.reminderSwitch.sendActions(for: .valueChanged)
        XCTAssertEqual(controller.reminderSwitch.isOn, false)
        XCTAssertEqual((router.presented as? UIAlertController)?.title, "Permission Needed")
        router.presented?.dismiss(animated: false)
        controller.reminderSwitch.isOn = false
        controller.reminderSwitch.sendActions(for: .valueChanged)
        XCTAssertEqual(controller.reminderDateButton.isHidden, true)
        XCTAssertFalse(router.presented is CoreHostingController<CoreDatePickerActionSheetCard>)

        notificationCenter.authorized = true
        notificationCenter.error = nil
        controller.reminderSwitch.isOn = true
        controller.reminderSwitch.sendActions(for: .valueChanged)
        XCTAssertEqual(controller.reminderDateButton.isHidden, false)
        controller.reminderDateButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.reminderDateButton.title(for: .normal), controller.selectedDate!.dateTimeString)
        XCTAssertGreaterThan(controller.selectedDate!, Clock.now)
        XCTAssertTrue(router.presented is CoreHostingController<CoreDatePickerActionSheetCard>)
    }
}
