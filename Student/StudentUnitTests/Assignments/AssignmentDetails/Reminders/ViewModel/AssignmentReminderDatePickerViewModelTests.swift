//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Combine
@testable import Student
import XCTest

class AssignmentReminderDatePickerViewModelTests: XCTestCase {
    private var selectedTimeIntervalReceiver: PassthroughSubject<DateComponents, Never>!
    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        selectedTimeIntervalReceiver = PassthroughSubject()
    }

    override func tearDown() {
        selectedTimeIntervalReceiver = nil
        subscriptions.removeAll()
        super.tearDown()
    }

    func testPickerOptions() {
        let testee = AssignmentReminderDatePickerViewModel(selectedTimeInterval: selectedTimeIntervalReceiver)

        XCTAssertEqual(testee.buttonTitles, [
            "5 Minutes",
            "15 Minutes",
            "30 Minutes",
            "1 Hour",
            "1 Day",
            "1 Week",
            "Custom",
        ])
    }

    func testInitialState() {
        let testee = AssignmentReminderDatePickerViewModel(selectedTimeInterval: selectedTimeIntervalReceiver)

        XCTAssertFalse(testee.doneButtonActive)
        XCTAssertFalse(testee.customPickerVisible)
        XCTAssertNil(testee.selectedButton)
    }

    func testSelectingAnOptionEnablesDoneButton() {
        let testee = AssignmentReminderDatePickerViewModel(selectedTimeInterval: selectedTimeIntervalReceiver)

        testee.buttonDidTap(title: "5 Minutes")

        XCTAssertTrue(testee.doneButtonActive)
    }

    func testSelectingCustomOptionEnablesCustomPicker() {
        let testee = AssignmentReminderDatePickerViewModel(selectedTimeInterval: selectedTimeIntervalReceiver)

        testee.buttonDidTap(title: "Custom")

        XCTAssertTrue(testee.customPickerVisible)
    }

    func testDoneTapOnPredefinedTime() {
        let testee = AssignmentReminderDatePickerViewModel(selectedTimeInterval: selectedTimeIntervalReceiver)

        let selectedTimeReportExpectation = expectation(description: "Time selected")
        selectedTimeIntervalReceiver
            .print()
            .collect(6)
            .sink { dateComponents in
                selectedTimeReportExpectation.fulfill()
                XCTAssertEqual(dateComponents, [
                    .init(minute: 5),
                    .init(minute: 15),
                    .init(minute: 30),
                    .init(hour: 1),
                    .init(day: 1),
                    .init(weekOfMonth: 1),
                ])
            }
            .store(in: &subscriptions)

        // WHEN
        testee.buttonDidTap(title: "5 Minutes")
        testee.doneButtonDidTap()
        testee.buttonDidTap(title: "15 Minutes")
        testee.doneButtonDidTap()
        testee.buttonDidTap(title: "30 Minutes")
        testee.doneButtonDidTap()
        testee.buttonDidTap(title: "1 Hour")
        testee.doneButtonDidTap()
        testee.buttonDidTap(title: "1 Day")
        testee.doneButtonDidTap()
        testee.buttonDidTap(title: "1 Week")
        testee.doneButtonDidTap()

        // THEN
        waitForExpectations(timeout: 1)
    }
}
