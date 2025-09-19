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

import Foundation
import XCTest
@testable import Core

final class DueDateFormatterTests: CoreTestCase {

    private static let testData = (
        date1: Date.make(year: 2025, month: 1, day: 15, hour: 14, minute: 30),
        date2: Date.make(year: 2025, month: 2, day: 10, hour: 9, minute: 15),
        lockDate: Date.make(year: 2025, month: 1, day: 20, hour: 23, minute: 59)
    )
    private lazy var testData = Self.testData

    // MARK: - Format using dates

    func test_format_whenDueDateNil_shouldReturnNoDueDateText() {
        XCTAssertEqual(
            DueDateFormatter.format(nil),
            DueDateFormatter.noDueDateText
        )
    }

    func test_format_whenDueDateProvided_shouldReturnFormattedDateWithPrefix() {
        XCTAssertEqual(
            DueDateFormatter.format(testData.date1),
            DueDateFormatter.dateText(testData.date1)
        )
    }

    func test_format_whenHasOverridesTrue_shouldReturnMultipleDueDatesText() {
        XCTAssertEqual(
            DueDateFormatter.format(testData.date1, hasOverrides: true),
            DueDateFormatter.multipleDueDatesText
        )
    }

    func test_format_whenLockDatePassed_shouldReturnAvailabilityClosedText() {
        let pastLockDate = testData.lockDate.addDays(-10)
        Clock.mockNow(testData.lockDate)

        XCTAssertEqual(
            DueDateFormatter.format(testData.date1, lockDate: pastLockDate),
            DueDateFormatter.availabilityClosedText
        )

        Clock.reset()
    }

    func test_format_whenLockDateFuture_shouldReturnNormalFormat() {
        let futureLockDate = testData.lockDate.addDays(10)
        Clock.mockNow(testData.lockDate)

        XCTAssertEqual(
            DueDateFormatter.format(testData.date1, lockDate: futureLockDate),
            DueDateFormatter.dateText(testData.date1)
        )

        Clock.reset()
    }

    // MARK: - Format without Prefix

    func test_formatWithoutPrefix_whenDueDateNil_shouldReturnNoDueDateText() {
        XCTAssertEqual(
            DueDateFormatter.formatWithoutPrefix(nil),
            DueDateFormatter.noDueDateText
        )
    }

    func test_formatWithoutPrefix_whenDueDateProvided_shouldReturnFormattedDateWithoutPrefix() {
        XCTAssertEqual(
            DueDateFormatter.formatWithoutPrefix(testData.date1),
            DueDateFormatter.dateTextWithoutDue(testData.date1)
        )
    }

    func test_formatWithoutPrefix_whenHasOverridesTrue_shouldReturnMultipleDueDatesText() {
        XCTAssertEqual(
            DueDateFormatter.formatWithoutPrefix(testData.date1, hasOverrides: true),
            DueDateFormatter.multipleDueDatesText
        )
    }

    func test_formatWithoutPrefix_whenLockDatePassed_shouldReturnAvailabilityClosedText() {
        let pastLockDate = testData.lockDate.addDays(-10)
        Clock.mockNow(testData.lockDate)

        XCTAssertEqual(
            DueDateFormatter.formatWithoutPrefix(testData.date1, lockDate: pastLockDate),
            DueDateFormatter.availabilityClosedText
        )
        Clock.reset()
    }

    // MARK: - Format using DueDateSummary

    func test_format_whenNoDueDateAndPrefixTrue_shouldReturnNoDueDateText() {
        XCTAssertEqual(
            DueDateFormatter.format(.noDueDate, addDuePrefix: true),
            DueDateFormatter.noDueDateText
        )
    }

    func test_format_whenNoDueDateAndPrefixFalse_shouldReturnNoDueDateText() {
        XCTAssertEqual(
            DueDateFormatter.format(.noDueDate, addDuePrefix: false),
            DueDateFormatter.noDueDateText
        )
    }

    func test_format_whenDueDateAndPrefixTrue_shouldReturnDateTextWithPrefix() {
        XCTAssertEqual(
            DueDateFormatter.format(.dueDate(testData.date1), addDuePrefix: true),
            DueDateFormatter.dateText(testData.date1)
        )
    }

    func test_format_whenDueDateAndPrefixFalse_shouldReturnDateTextWithoutPrefix() {
        XCTAssertEqual(
            DueDateFormatter.format(.dueDate(testData.date1), addDuePrefix: false),
            DueDateFormatter.dateTextWithoutDue(testData.date1)
        )
    }

    func test_format_whenAvailabilityClosedAndPrefixTrue_shouldReturnAvailabilityClosedText() {
        XCTAssertEqual(
            DueDateFormatter.format(.availabilityClosed, addDuePrefix: true),
            DueDateFormatter.availabilityClosedText
        )
    }

    func test_format_whenAvailabilityClosedAndPrefixFalse_shouldReturnAvailabilityClosedText() {
        XCTAssertEqual(
            DueDateFormatter.format(.availabilityClosed, addDuePrefix: false),
            DueDateFormatter.availabilityClosedText
        )
    }

    func test_format_whenMultipleDueDatesAndPrefixTrue_shouldReturnMultipleDueDatesText() {
        XCTAssertEqual(
            DueDateFormatter.format(.multipleDueDates, addDuePrefix: true),
            DueDateFormatter.multipleDueDatesText
        )
    }

    func test_format_whenMultipleDueDatesAndPrefixFalse_shouldReturnMultipleDueDatesText() {
        XCTAssertEqual(
            DueDateFormatter.format(.multipleDueDates, addDuePrefix: false),
            DueDateFormatter.multipleDueDatesText
        )
    }

    // MARK: - Formatted texts

    func test_dateText_shouldReturnLocalizedStringWithDuePrefix() {
        let result = DueDateFormatter.dateText(testData.date1)
        let expectedFormat = String(localized: "Due %@", bundle: .core)
        let expectedString = String.localizedStringWithFormat(expectedFormat, testData.date1.relativeDateTimeString)

        XCTAssertEqual(result, expectedString)
    }

    func test_dateTextWithoutDue_shouldReturnRelativeDateTimeString() {
        XCTAssertEqual(
            DueDateFormatter.dateTextWithoutDue(testData.date1),
            testData.date1.relativeDateTimeString
        )
    }

    func test_noDueDateText_shouldReturnLocalizedString() {
        XCTAssertEqual(DueDateFormatter.noDueDateText, "No Due Date")
    }

    func test_availabilityClosedText_shouldReturnLocalizedString() {
        XCTAssertEqual(DueDateFormatter.availabilityClosedText, "Closed For Submission")
    }

    func test_multipleDueDatesText_shouldReturnLocalizedString() {
        XCTAssertEqual(DueDateFormatter.multipleDueDatesText, "Multiple Due Dates")
    }
}
