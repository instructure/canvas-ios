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
import TestsFoundation
import XCTest

class AssignmentReminderDatePickerViewModelTests: XCTestCase {
    private var selectedTimeIntervalReceiver: PassthroughSubject<DateComponents, Never>!
    private var subscriptions = Set<AnyCancellable>()
    private var testRouter: TestRouter!

    override func setUp() {
        super.setUp()
        selectedTimeIntervalReceiver = PassthroughSubject()
        testRouter = TestRouter()
    }

    override func tearDown() {
        selectedTimeIntervalReceiver = nil
        subscriptions.removeAll()
        super.tearDown()
    }

    func testPickerOptions() {
        let testee = AssignmentReminderDatePickerViewModel(selectedTimeInterval: selectedTimeIntervalReceiver)

        XCTAssertEqual(testee.buttonTitles, [
            "5 Minutes Before",
            "15 Minutes Before",
            "30 Minutes Before",
            "1 Hour Before",
            "1 Day Before",
            "1 Week Before",
            "Custom"
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

        testee.buttonDidTap(title: "5 Minutes Before")

        XCTAssertTrue(testee.doneButtonActive)
    }

    func testSelectingCustomOptionEnablesCustomPicker() {
        let testee = AssignmentReminderDatePickerViewModel(selectedTimeInterval: selectedTimeIntervalReceiver)

        testee.buttonDidTap(title: "Custom")

        XCTAssertTrue(testee.customPickerVisible)
    }

    func testDoneTapOnPredefinedTimes() {
        let testee = AssignmentReminderDatePickerViewModel(selectedTimeInterval: selectedTimeIntervalReceiver)
        let host = UIViewController()
        let selectedTimeReportExpectation = expectation(description: "Time selected")
        selectedTimeIntervalReceiver
            .collect(6)
            .sink { dateComponents in
                selectedTimeReportExpectation.fulfill()
                XCTAssertEqual(dateComponents, [
                    .init(minute: 5),
                    .init(minute: 15),
                    .init(minute: 30),
                    .init(hour: 1),
                    .init(day: 1),
                    .init(weekOfMonth: 1)
                ])
            }
            .store(in: &subscriptions)

        // WHEN
        testee.buttonDidTap(title: "5 Minutes Before")
        testee.doneButtonDidTap(host: host)
        testee.buttonDidTap(title: "15 Minutes Before")
        testee.doneButtonDidTap(host: host)
        testee.buttonDidTap(title: "30 Minutes Before")
        testee.doneButtonDidTap(host: host)
        testee.buttonDidTap(title: "1 Hour Before")
        testee.doneButtonDidTap(host: host)
        testee.buttonDidTap(title: "1 Day Before")
        testee.doneButtonDidTap(host: host)
        testee.buttonDidTap(title: "1 Week Before")
        testee.doneButtonDidTap(host: host)

        // THEN
        waitForExpectations(timeout: 1)
    }

    func testDoneTapOnCustomIntervals() {
        let testee = AssignmentReminderDatePickerViewModel(selectedTimeInterval: selectedTimeIntervalReceiver)
        let host = UIViewController()
        let selectedTimeReportExpectation = expectation(description: "Time selected")
        selectedTimeIntervalReceiver
            .collect(4)
            .sink { dateComponents in
                selectedTimeReportExpectation.fulfill()
                XCTAssertEqual(dateComponents, [
                    DateComponents(minute: 66),
                    DateComponents(hour: 66),
                    DateComponents(day: 66),
                    DateComponents(weekOfMonth: 66)
                ])
            }
            .store(in: &subscriptions)
        testee.buttonDidTap(title: "Custom")
        testee.customValue = 66

        // WHEN
        testee.customMetric = .minutes
        testee.doneButtonDidTap(host: host)
        testee.customMetric = .hours
        testee.doneButtonDidTap(host: host)
        testee.customMetric = .days
        testee.doneButtonDidTap(host: host)
        testee.customMetric = .weeks
        testee.doneButtonDidTap(host: host)

        // THEN
        waitForExpectations(timeout: 1)
    }
}
